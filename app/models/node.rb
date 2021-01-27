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

  belongs_to :author
  belongs_to :parent, class_name: "Node", optional: true
  has_many :content_versions
  has_one :content, -> { order(created_at: :desc).limit(1) }, class_name: "ContentVersion"

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

  has_many :descendants, class_name: "NodeDescendantsIncr", foreign_key: :base_id
  has_many :readable_descendants, class_name: "NodeReadableDescendant", foreign_key: :base_id

  before_create :set_node_cache_init
  after_create :refresh_node_views

  def refresh_node_views
    # NodeViewsWorker.perform_in 3.seconds
    # this will refresh basically everything underneath -- fast enough to run in main thread now
    NodeInheritedAuthzRead.refresh
  end

  # def children(user, limit: 1000)
  #   nar = Arel::Table.new :nar
  #   q =
  #     Node.join_with_author_username(
  #       Node.join_with_author(
  #         Node.join_with_content(
  #           Node.nodes_readable_by(user).where(nar[:parent_id].eq(id)).take(limit)
  #         )
  #       )
  #     )
  #   Node.find_by_sql(q)
  # end
  def children(user)
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

  def descendants(user)
    q = Node.descendants_readable_by(id, user)
    q = block q if block_given?
    Node.find_by_sql(
      Node.join_with_author_username(
        Node.join_with_author(
          Node.join_with_content(
            q
          )
        )
      ).order(:id)
    )
  end

  def descendants_map(user)
    # get this node + children
    tree = [self] + descendants(user)
    # defaultdict where a key will return an empty array by defualt
    node_id_to_children = Hash.new { |h, k| h[k] = Array.new }
    tree.each do |n|
      # for each node, append it's children to the corresponding array in the hash
      node_id_to_children[n.parent_id] << n
      if n.id == self.id
        node_id_to_children[-1] << n
      end
    end
    node_id_to_children
  end

  def formatted_name
    self.author.formatted_name
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

  # do not use unless you're benchmarking
  def descendants_via_arhq
    Node.join_recursive do |q|
      q.start_with(id: self.id)
       .connect_by(id: :parent_id)
    end if Rails.env.development?
  end

  # do not use unless you're benchmarking
  def ancestors_via_arhq
    Node.join_recursive do |q|
      q.start_with(id: self.id)
        .connect_by(parent_id: :id)
    end if Rails.env.development?
  end

  def view
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

  def who_can_read
    throw "deprecated"
    gs_raw = ActiveRecord::Base.connection.execute Node.node_authz_groups_for(id).to_sql
    gs_raw.to_a.collect { |g| g[:group_name.to_s] }
  end

  class << self
    def root
      throw "deprecated, use find_readable, with_descendants, or with_descendants_map instead"
      Node.find(0)
    end

    def table
      arel_table
    end

    def with_children(node_id, user)
      return Node.find_readable(node_id, user)
      Node
        .includes(direct_children: [:content, :author, :user, :readable_by_users])
        .joins(:readable_by_users)
        .includes(:content)
        .includes(:author)
        .includes(:user)
        .where(nodes_readables: { user_id: user })
        .find(node_id)
    end

    def with_descendants(node_id, user, max_branch_depth: 3)
      # this works but is sorta slow; tho faster than without materialized views
      nr = NodesReadable.arel_table
      nd = NodeDescendant.arel_table
      q = table
        .join(nd)
        .on(nd[:id].eq(table[:id]))
        .where(nd[:base_id].eq(node_id))
        .where(nd[:distance].lteq(max_branch_depth))
        .join(nr)
        .on(nr[:node_id].eq(table[:id]))
        .where(nr[:user_id].eq(user&.id))
        .project(table[Arel.star])
        .order(:id)
      r = Node.find_by_sql q
      return r

      #  .where("node_readable_descendants.distance < ?", max_branch_depth)
      #  .where(node_readable_descendants: { user_id: user })
    end

    def with_descendants_map(node_id, user, max_branch_depth: 3)
      node_id = node_id.to_i
      # get this node + children
      nodes = with_descendants(node_id, user, max_branch_depth: max_branch_depth)
      # defaultdict where a key will return an empty array by defualt
      node_id_to_children = Hash.new { |h, k| h[k] = Array.new }
      nodes.each do |n|
        # for each node, append it's children to the corresponding array in the hash
        node_id_to_children[n.parent_id] << n
        if n.id == node_id
          node_id_to_children[-1] << n
        end
      end
      node_id_to_children
    end

    # returns (base_id, ...node)
    def relatives_via_arel_mgr(ascending, base_node_id = nil, max_rel_depth = nil)
      hierarchy = Arel::Table.new :hierarchy
      recursive_table = Arel::Table.new(table_name).alias :recursive
      select_manager = Arel::SelectManager.new(ActiveRecord::Base).freeze

      non_recursive_term = select_manager.dup.tap do |m|
        m.from table_name
        m.project table[:id].as("base_id"), Arel.star, Arel::Nodes::SqlLiteral.new("0").as("rel_depth")
        unless base_node_id.nil?
          m.where table[:id].eq(base_node_id)
        end
      end

      recursive_term = select_manager.dup.tap do |m|
        m.from recursive_table
        m.project hierarchy[:base_id], recursive_table[Arel.star], hierarchy[:rel_depth] + 1
        m.join hierarchy
        if ascending
          # take parent_id from results and match to id of node; add node to results
          m.on recursive_table[:id].eq(hierarchy[:parent_id])
        else
          m.on recursive_table[:parent_id].eq(hierarchy[:id])
        end
        (m.where hierarchy[:rel_depth].lteq(max_rel_depth)) unless max_rel_depth.nil?
      end

      union = non_recursive_term.union :all, recursive_term
      as_statement = Arel::Nodes::As.new hierarchy, union

      manager = select_manager.dup.tap do |m|
        m.with :recursive, as_statement
        m.from hierarchy
        m.project hierarchy[Arel.star]
      end
    end

    def all_descendants_via_arel_mgr
      relatives_via_arel_mgr(false)
    end

    def all_descendants_via_arel
      find_by_sql all_descendants_via_arel_mgr
    end

    def all_ancestors_via_arel_mgr
      relatives_via_arel_mgr(true)
    end

    def all_ancestors_via_arel
      find_by_sql all_ancestors_via_arel_mgr
    end

    # returns (...node, td_tag, ut_tag)
    def node_system_tag_combos
      n = Node.table
      sts = Arel::Table.new :system_tags
      n
        .join(sts)
        .on(n[:id].eq(sts[:anchored_id]).and(sts[:anchored_type].eq(Node.name)))
        .with(TagDecl.system_tags.as(:system_tags.to_s))
        .project(n[Arel.star], sts[:td_tag], sts[:ut_tag])
    end

    def all_node_system_tag_combos
      find_by_sql node_system_tag_combos
    end

    # returns (base_id, ...node, td_tag, ut_tag)
    def all_node_authz_reads
      nwa = Arel::Table.new :nwa
      nstc = Arel::Table.new :nstc

      Arel::SelectManager.new
        .project(nwa[Arel::star], nstc[:ut_tag])
        .from(all_ancestors_via_arel_mgr.as("nwa"))
        .join(node_system_tag_combos.as("nstc"))
        .on(nstc[:id].eq(nwa[:id]))
        .where(nstc[:td_tag].eq(Authz.read))
    end

    def anar_closest_parent
      anar = Arel::Table.new :anar

      Arel::SelectManager.new
        .project(anar[:base_id], anar[:id].maximum.as("closest_permission_id"))
        .from(all_node_authz_reads.as("anar"))
        .group(anar[:base_id])
    end

    def with_permissioned_parent
      acp = Arel::Table.new :acp
      table
        .join(anar_closest_parent.as("acp"))
        .on(table[:id].eq(acp[:base_id]))
        .project(table[Arel.star], acp[:closest_permission_id])
    end

    def old_node_authz_read
      acp = Arel::Table.new :acp
      anar = Arel::Table.new :anar
      Arel::SelectManager.new
        .project(acp[:base_id], anar[:ut_tag].as("group_name"))
        .from(anar_closest_parent.as("acp"))
        .join(all_node_authz_reads.as("anar"))
        .on(anar[:id].eq(acp[:closest_permission_id]))
    end

    def old_nodes_readable_by(user)
      nar = Arel::Table.new :nar
      Arel::SelectManager.new
        .from(old_node_authz_read.as("nar"))
        .where(nar[:group_name].eq("all").or(nar[:group_name].in(user&.groups_arel)))
        .project(nar[Arel.star])
    end

    def node_authz_read
      wpp = Arel::Table.new :wpp
      nstc = Arel::Table.new :nstc
      Arel::SelectManager.new
        .from(with_permissioned_parent.as("wpp"))
        .join(node_system_tag_combos.as("nstc"))
        .on(nstc[:id].eq(wpp[:closest_permission_id]))
        .where(nstc[:td_tag].eq(Authz.read))
        .project(wpp[Arel.star], nstc[:ut_tag].as("group_name"))
    end

    def node_authz_read_for(node_id)
      wpp = Arel::Table.new :wpp
      node_authz_read.where(wpp[:id].eq(node_id))
    end

    def node_authz_groups_for(node_id)
      narf = Arel::Table.new :narf
      Arel::SelectManager.new
        .from(node_authz_read_for(node_id).as("narf"))
        .project(narf[:group_name])
    end

    def nodes_readable_by(maybe_user)
      nar = Arel::Table.new :nar
      q = Arel::SelectManager.new
        .from(node_authz_read.as("nar"))
        .where(nar[:group_name].eq("all").or(nar[:group_name].in(maybe_user&.groups_arel)))
        .project(nar[Arel.star])
        .order(nar[:id])
    end

    def descendants_readable_by(node_id, maybe_user, max_branch_depth = 3)
      nar = Arel::Table.new :nar
      nwc = Arel::Table.new :nwc

      q = Arel::SelectManager.new
        .from(node_authz_read.as("nar"))
        .join(relatives_via_arel_mgr(false, node_id, max_branch_depth).as("nwc"))
        .on(nar[:id].eq(nwc[:id]))
        .where(nar[:group_name].eq("all").or(nar[:group_name].in(maybe_user&.groups_arel || [])))
        .project(nar[Arel.star])
    end

    def get_nodes_readable_by(user)
      nodes_readable_by(user)
    end

    def get_old_nodes_readable_by(user)
      find_by_sql old_nodes_readable_by(user)
    end

    def join_with_content(nodes_query, on: :id)
      # return nodes_query.joins(:content_versions)
      cvs = ContentVersion.arel_table
      n = Arel::Table.new :n

      Arel::SelectManager.new
        .project(n[Arel.star], cvs[:body], cvs[:title], cvs[:author_id].as(:content_author_id.to_s))
        .from(nodes_query.as("n"))
        .join(cvs)
        .on(n[on].eq(cvs[:node_id]))
        .order(cvs[:created_at])
    end

    def join_with_author(nodes_query, on: :content_author_id)
      # return nodes_query.joins(:author)
      authors = Author.arel_table
      n = Arel::Table.new :n
      Arel::SelectManager.new
        .project(n[Arel.star], authors[:name].as("author_name"), authors[:user_id].as("author_user_id"))
        .from(nodes_query.as("n"))
        .join(authors)
        .on(n[on].eq(authors[:id]))
    end

    def join_with(nodes_query, cls, on, foreign_key: :id, project: [])
      f = cls.arel_table
      n = Arel::Table.new :n
      to_project = project.map { |p| f[p] }
      Arel::SelectManager.new
        .project(n[Arel.star], *to_project)
        .from(nodes_query.as("n"))
        .join(f)
        .on(n[on].eq(f[foreign_key]))
    end

    def join_with_author_username(q)
      # return q.join(:user)
      join_with(q, User, :author_user_id, project: [:username])
    end

    def find_readable(id, user)
      Node
        .joins(:readable_by_users)
        .includes(:content)
        .includes(:author)
        .includes(:user)
        .where(nodes_readables: { user_id: user })
        .find(id)
      # .find(id)
      # .where(id: id).first
      # nar = Arel::Table.new :nar
      # q =
      #   join_with_author_username(
      #     join_with_author(
      #       join_with_content(
      #         nodes_readable_by(user).where(nar[:id].eq(id))
      #       )
      #     )
      #   )
      # find_by_sql(q).first
    end
  end

  private

  def set_node_cache_init
    if self.depth.nil? && self.parent_id.nil?
      self.depth = 0
    end
  end
end
