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

  has_many :node_authz_reads, foreign_key: :base_node_id

  after_create :set_tags

  # scope :is_top_post, -> (x) { where(is_top_post: x) }
  # scope :genesis, -> (x) { where(genesis_id: x.id) }

  def children(user_id)
    user_id_comp = user_id.nil? ? "IS" : "="
    # return Node.where("id in (
    #   SELECT nwc.id FROM nodes_user_sees nus
    #   JOIN node_with_children nwc ON nwc.id = nus.base_node_id
    #   WHERE nwc.base_node_id = ? AND rel_depth = 1 AND nus.user_id #{user_id_comp} ?
    # )", self.id, user_id)
    # alt implementation that might/should be faster
    Node.where("id in (
      SELECT nus.base_node_id FROM nodes_user_sees nus
      JOIN nodes n ON n.id = nus.base_node_id
      WHERE n.parent_id = ? AND nus.user_id #{user_id_comp} ?
    )", self.id, user_id)
  end

  def content
    content_versions.last
  end

  def depth
    if self.parent == nil
      0
    else
      self.parent.depth + 1
    end
  end

  # def children
  #   Node.where("id in (
  #     SELECT id FROM node_with_children WHERE base_node_id = #{self.id} AND rel_depth = 1
  #   )")
  # end

  def descendants(user_id)
    # todo: refactor this and .children into the same basic function - parameterized
    user_id_comp = user_id.nil? ? "IS" : "="
    Node.where("id in (
      SELECT nwc.id FROM nodes_user_sees nus
      JOIN node_with_children nwc ON nwc.id = nus.base_node_id
      WHERE nwc.base_node_id = ? AND rel_depth > 0 AND nus.user_id #{user_id_comp} ?
    )", self.id, user_id)
  end

  def view
    self.anchored_view_tags.last.tag
  end

  def descendants_map(user_id)
    # get this node + children
    tree = [self] + self.descendants(user_id)
    # defaultdict where a key will return an empty array by defualt
    node_id_to_children = Hash.new { |h, k| h[k] = Array.new }
    tree.each do |n|
      # for each node, append it's children to the corresponding array in the hash
      node_id_to_children[n.id] += (tree.select { |n2| n2.parent_id == n.id })
    end
    return node_id_to_children
  end

  def who_can_read
    can_read = self.node_authz_reads.collect { |nar| nar.group_name }
    puts self.node_authz_reads, can_read, "^^^ can read"
    return can_read
  end

  def all_tags
    ActiveRecord::Base.connection.execute self.get_all_tags_sql self, "authz_read"
  end

  def with_parents2
    Node.where("id in (SELECT id FROM (#{self.node_and_parents_rec_sql}))")
  end

  class << self
    def root
      Node.find(0)
    end
  end

  private

  def children_rec_sql(node = self, user_id = nil)
    table_name = Node.table_name
    <<-SQL
        WITH RECURSIVE search_tree(id) AS (
            SELECT id
            FROM #{table_name}
            WHERE id = #{node.id}
          UNION ALL
            SELECT o.id
            FROM search_tree, #{table_name} o
            WHERE search_tree.id = o.parent_id
        ),
        tag_combos(node_id, tag, ut_id, ut_tag) AS (
          #{self.tag_combos_with_table_named("search_tree")}
        ),
        user_groups(group_name) AS (
          #{self.user_groups_sql(user_id)}
        ),
        authz_read(id) AS (
          SELECT id
          FROM search_tree
          JOIN tag_combos tc ON tc.node_id = id
          JOIN user_groups ug ON tc.ut_tag = ug.group_name OR tc.ut_tag = 'all'
        )
        SELECT * FROM authz_read
    SQL
  end

  def tag_combos_with_table_named(table_name)
    <<-SQL
      SELECT n.id, td.tag, ut.id, ut.tag
      FROM #{table_name} n
      JOIN tag_decls td ON td.anchored_id = n.id
      JOIN user_tags ut ON td.target_id = ut.id
      WHERE 1
        AND td.tag = 'authz_read'
        AND td.target_type = 'UserTag'
        AND td.anchored_type = 'Node'
        AND td.user_id IS NULL
        AND ut.user_id IS NULL
    SQL
  end

  def user_groups_sql(user_id)
    <<-SQL
      SELECT 'all'
      UNION ALL
      SELECT ut.tag
      FROM tag_decls td
      JOIN user_tags ut ON td.target_id = ut.id
      WHERE 1
        AND td.anchored_type = 'User'
        AND td.anchored_id = #{user_id}
        AND td.target_type = 'UserTag'
        AND td.user_id IS NULL
        AND ut.user_id IS NULL
    SQL
  end

  # node_and_parents_rec
  def node_and_parents_rec_sql(node = self)
    <<-SQL
      WITH RECURSIVE 
      node_and_parents(id, parent_id) AS (
        #{self.node_and_parents_rec_sql_inner(node)}
      )
      SELECT n.* FROM nodes n, node_and_parents np WHERE n.id = np.id 
    SQL
  end

  # node_and_parents_rec
  def node_and_parents_rec_sql_inner(node = self)
    <<-SQL
        SELECT id, parent_id
        FROM nodes
        WHERE id = #{node.id}
        UNION ALL
        SELECT n.id, n.parent_id
        FROM node_and_parents np, nodes n
        WHERE np.parent_id = n.id
    SQL
  end

  # # node_and_parents_rec
  # def node_and_parents_rec_sql_copy(node = self)
  #   <<-SQL
  #     WITH RECURSIVE
  #     node_and_parents(id, parent_id) AS (
  #       SELECT id, parent_id
  #       FROM nodes
  #       WHERE id = #{node.id}
  #       UNION ALL
  #       SELECT n.id, n.parent_id
  #       FROM node_and_parents np, nodes n
  #       WHERE np.parent_id = n.id
  #     )
  #     --SELECT * FROM node_and_parents
  #     SELECT * FROM nodes n, node_and_parents np WHERE n.id = np.id
  #   SQL
  # end

=begin
Find the authz_read tags for this node or the closest ancestor with an authz_read tag.
Returns a list of hashes with keys:
> node_id, tag, ut_id, ut_tag
=end

  def authz_read_sql(node = self)
    <<-SQL
      WITH
      tag_combos(node_id, tag, ut_id, ut_tag) AS (
        SELECT n.id, td.tag, ut.id, ut.tag
        FROM node_with_ancestors n
        JOIN tag_decls td ON td.anchored_id = n.id
        JOIN user_tags ut ON td.target_id = ut.id
        WHERE 1
          AND n.base_node_id = #{node.id}
          AND td.tag = 'authz_read'
          AND td.target_type = 'UserTag'
          AND td.anchored_type = 'Node'
      ),
      closest_node_id(node_id) AS (SELECT MAX(node_id) from tag_combos)
      SELECT tc.* FROM tag_combos tc, closest_node_id WHERE tc.node_id = closest_node_id.node_id
    SQL
  end

  def get_all_tags_sql(node = self, tag)
    # WARNING: UNSAFE SUBSTITUTION FOR TESTING
    <<-SQL
      WITH RECURSIVE 
      node_and_parents(id, parent_id) AS (
        #{self.node_and_parents_rec_sql_inner(node)}
      ),
      tag_combos(node_id, tag, target_type, target_id, ut_tag) AS (
        SELECT n.id, td.tag, td.target_type, td.target_id, ut.tag
        FROM node_and_parents n
        JOIN tag_decls td ON td.anchored_id = n.id
        JOIN user_tags ut ON td.target_id = ut.id
        WHERE 1
          AND td.tag = '#{tag}'
          AND td.target_type = 'UserTag'
          AND td.anchored_type = 'Node'
      ),
      closest_node_id(node_id) AS (SELECT MAX(node_id) from tag_combos)
      SELECT tc.* FROM tag_combos tc, closest_node_id WHERE tc.node_id = closest_node_id.node_id
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
