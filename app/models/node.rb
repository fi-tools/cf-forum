class Node < ApplicationRecord
  belongs_to :author
  belongs_to :parent, class_name: "Node", optional: true
  has_many :content_versions

  has_one :user, through: :author
  has_many :direct_children, class_name: "Node", foreign_key: :parent_id

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"
  has_many :anchored_usertags, through: :anchoring_tags, source: :target, source_type: "UserTag"

  # has_many
  has_many :anchoring_view_tags, as: :anchored, class_name: "ViewTagDecl"
  has_many :anchored_view_tags, through: :anchoring_view_tags, source: :target, source_type: "UserTag"

  has_many :anchoring_authz_tags, as: :anchored, class_name: "AuthzTagDecl"
  # we don't want to find just the UserTags associated with Authz; that's not v useful on its own.
  # has_many :anchored_authz_tags, through: :anchoring_authz_tags, source: :target, source_type: "UserTag"

  after_create :set_tags

  # scope :is_top_post, -> (x) { where(is_top_post: x) }
  # scope :genesis, -> (x) { where(genesis_id: x.id) }

  # def children
  #   Node.where(parent_id: self.id).all()
  # end

  def content
    c = content_versions.last
    # puts c
    # puts c.title
    # # puts content_versions.last.methods
    # puts "^ content versions"
    c
  end

  def content_version
    warn "Deprecation: Node.content_version"
    content
  end

  def depth
    if self.parent == nil
      0
    else
      self.parent.depth + 1
    end
  end

  def children_rec(rec = false)
    if !rec
      return direct_children
    end
    Node.where("id in (#{self.children_rec_sql(self)}) AND id != ?", [self.id])
  end

  def view
    puts self.anchoring_view_tags.all
    self.anchored_view_tags.last.tag
  end

  def family_map
    # get this node + children
    tree = [self] + self.children_rec(true)
    # defaultdict where a key will return an empty array by defualt
    node_id_to_children = Hash.new { |h, k| h[k] = Array.new }
    tree.each do |n|
      # for each node, append it's children to the corresponding array in the hash
      node_id_to_children[n.id] += (tree.select { |n2| n2.parent_id == n.id })
    end
    return node_id_to_children
  end

  class << self
    def root
      Node.find(0)
    end
  end

  private

  def children_rec_sql(node)
    table_name = Node.table_name
    <<-SQL
        WITH RECURSIVE search_tree(p_id) AS (
            SELECT id
            FROM #{table_name}
            WHERE id = #{node.id}
          UNION ALL
            SELECT id
            FROM search_tree, #{table_name} o
            WHERE search_tree.p_id = o.parent_id
        )
        SELECT * FROM search_tree
    SQL
  end

  def set_tags
    self.set_view_tag_from_parent
    # let's not set default permissions like this. probs better to do inheretance properly.
    # self.set_permissions_from_parent
  end

  def set_view_tag_from_parent
    p = self.parent
    if !p.nil?
      view_tag = p.anchored_view_tags.last
      if view_tag.nil?
        throw "No tags :*( #{p.to_yaml}"
      end
      new_vt = DEFAULT_VIEW_PROGRESSION[view_tag.tag]
      logger.debug "new_vt: #{new_vt} from #{view_tag.tag}"
      TagDecl.create! :tag => :view, :user => nil, :anchored => self, :target => UserTag.find_global(new_vt).first
    end
  end

  # note: let's not do autosetting permissions like this. it is confusing and mb will do
  # things ppl don't predict. rather we can just set up the top level permissions early
  # and do inheretance right.
  # def set_permissions_from_parent
  #   p = self.parent
  #   if !p.nil?
  #     authz_tags = p.anchoring_authz_tags.all
  #     logger.debug "authz_tags: #{authz_tags.to_json}"
  #     crash!
  #   else
  #     logger.warn "set_permissions_from_parent > no parent"
  #   end
  # end
end

DEFAULT_VIEW_PROGRESSION = {
  "root" => :index,
  "index" => :topic,
  "topic" => :comment,
  "comment" => :comment,
}

# PERMISSIONS_PROGRESSION = {
#   "read_node" => :authz_write_children,
# }
