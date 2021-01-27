require "active_record/hierarchical_query"

class Node < ApplicationRecord
  <<~END
    The Node object -- the primary object in the discussion tree

    ## usage

    Typically you should find nodes using a method that considers permissions, e.g.:
    `Node.find_readable(_id)`

    ## notes

    ### 'recursive' queries with rails

    We can do 'recursive' queries with just rails like:
    Node.includes(parent: [:parent, { parent: [:parent] }])
    Node.includes(direct_children: [:direct_children, { direct_children: [:direct_children] }])
  END

  # belongs_to :author
  belongs_to :parent, class_name: "Node", optional: true
  has_many :content_versions
  has_one :content, -> { order(created_at: :desc).limit(1) }, class_name: "ContentVersion"

  has_one :author, through: :content
  has_one :user, through: :author
  has_many :direct_children, class_name: "Node", foreign_key: :parent_id
  # has_many :readable_children_links, class_name: "NodesReadable", foreign_key: :node_id
  # has_many :readable_children, through: :readable_children_links, class_name: "Node"

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"
  has_many :anchored_usertags, through: :anchoring_tags, source: :target, source_type: "UserTag"

  # has_many
  has_many :anchoring_view_tags, as: :anchored, class_name: "ViewTagDecl"
  has_many :anchored_view_tags, through: :anchoring_view_tags, source: :target, source_type: "UserTag"

  has_many :anchoring_authz_tags, as: :anchored, class_name: "AuthzTagDecl"
  # we don't want to find just the UserTags associated with Authz; that's not v useful on its own.
  # has_many :anchored_authz_tags, through: :anchoring_authz_tags, source: :target, source_type: "UserTag"

  has_many :system_tag_decls, as: :anchored
  has_many :system_user_tags, through: :system_tag_decls, source: :target, source_type: "UserTag"

  has_one :readable_by_groups, class_name: "NodeInheritedAuthzRead"
  has_many :readable_by_users, class_name: "NodesReadable"

  has_many :view_tags, -> { where(tag: "view", user_id: Arel::Nodes::Or.new(nil, @user_id)) }, as: :anchored, class_name: "TagDecl"
  has_many :views, -> { where(user_id: Arel::Nodes::Or.new(nil, @user_id)) }, through: :view_tags, source: :target, source_type: "UserTag"

  before_create :set_node_cache_init
  after_create :refresh_node_views

  def refresh_node_views
    # NodeViewsWorker.perform_in 3.seconds
    # this will refresh basically everything underneath -- fast enough to run in main thread now
    NodeInheritedAuthzRead.refresh
  end

  def children_direct(user)
    Node
      .joins(:readable_by_users)
      .includes(:content)
      .includes(:author)
      .includes(:user)
      .where(parent_id: id, direct_children: { nodes_readables: { user_id: user } })
      .order(id: :asc)
  end

  # def content
  #   content_versions.last
  # end

  def formatted_name
    self.author.formatted_name
  end

  def children_rec_arhq(user, **opts)
    Node.children_rec_arhq(id, user, **opts)
  end

  def title_w_default
    if self[:title]
      self[:title]
    elsif self[:body]
      n_chars = 40
      self[:body].slice(0, n_chars) + (self[:body].length > n_chars ? "..." : "")
    else
      self.content&.title
    end
  end

  def view
    return views.last unless views.empty?
    # todo: add way for view to be set to something else, ideally user controlled
    case self.depth
    when 0
      "root"
    when 1
      "index"
    else
      "topic"
    end
    # anchored_view_tags&.last&.tag || "topic"
  end

  class << self
    def table
      arel_table
    end

    def descendants_raw(node_id)
      Node.join_recursive { |q| q.start_with(id: node_id).connect_by(id: :parent_id) }
    end

    def children_rec_arhq(node_id, user, limit_nodes_lower: 140)
      descendants_map = Hash.new { |h, k| h[k] = Array.new }
      cs = Node
        .joins(:readable_by_groups)
        .where.overlap({ node_inherited_authz_reads: { groups: user&.groups || User.default_groups } })
        .join_recursive { |q| q.start_with(id: node_id).connect_by(id: :parent_id) }
        .limit(limit_nodes_lower)
        .eager_load(:content)
        .eager_load(:author)
        .eager_load(:user)
        .preload(:views) # eager_loading :views will do a join and massively slow down this query.
        .sort
      # sorting here adds 200ms!!! .order(id: :asc)
      cs.each { |n| descendants_map[n.parent_id] << n }
      branch_root = cs.find { |n| n.id == node_id }
      # descendants_map.each_value { |v| v.sort }
      # return fresh copy of this node as 3rd item
      return cs, descendants_map, branch_root
    end
  end

  private

  def set_node_cache_init
    if self.depth.nil? && self.parent_id.nil?
      self.depth = 0
    end
  end
end
