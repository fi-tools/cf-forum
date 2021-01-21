require "active_record/hierarchical_query"

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

  has_many :system_tag_decls, as: :anchored
  has_many :system_user_tags, through: :system_tag_decls, source: :target, source_type: "UserTag"

  has_many :node_authz_reads, foreign_key: :base_node_id

  after_create :set_tags

  # scope :is_top_post, -> (x) { where(is_top_post: x) }
  # scope :genesis, -> (x) { where(genesis_id: x.id) }

  def children(user_id)
    # user_id_comp = user_id.nil? ? "IS" : "="
    # return Node.where("id in (
    #   SELECT nwc.id FROM nodes_user_sees nus
    #   JOIN node_with_children nwc ON nwc.id = nus.base_node_id
    #   WHERE nwc.base_node_id = ? AND rel_depth = 1 AND nus.user_id #{user_id_comp} ?
    # )", self.id, user_id)
    # alt implementation that might/should be faster
    self.children_elegaint(user_id)
  end

  def children_elegaint(user_id)
    user_id_comp = user_id.nil? ? "IS" : "="
    Node.where("id in (
      SELECT nwc.id FROM nodes_user_sees nus
      JOIN node_with_children nwc ON nwc.id = nus.base_node_id
      WHERE nwc.base_node_id = ? AND rel_depth = 1 AND nus.user_id #{user_id_comp} ?
    )", self.id, user_id)
  end

  def children_elegaint_parent(user_id)
    user_id_comp = user_id.nil? ? "IS" : "="
    Node.where("id in (
      SELECT nus.base_node_id FROM nodes_user_sees nus
      JOIN nodes n ON n.id = nus.base_node_id
      WHERE n.parent_id = ? AND nus.user_id #{user_id_comp} ?
    )", self.id, user_id)
  end

  def children_manual(user_id)
    user_groups = user_id.nil? ? ["all"] : User.find(user_id).groups
    Node.where(:parent_id => @id)
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

  def descentands(user_id)
    self.descentands_elegaint(user_id)
  end

  def descentands_elegaint(user_id)
    # todo: refactor this and .children into the same basic function - parameterized
    user_id_comp = user_id.nil? ? "IS" : "="
    Node.where("id in (
      SELECT nwc.id FROM nodes_user_sees nus
      JOIN node_with_children nwc ON nwc.id = nus.base_node_id
      WHERE nwc.base_node_id = ? AND rel_depth > 0 AND nus.user_id #{user_id_comp} ?
    )", self.id, user_id)
  end

  def descendants_via_nwc_simple(user_id)
    Node.where("id in (
      SELECT nwc.id FROM node_with_children nwc
      WHERE nwc.base_node_id = ?
    )", self.id)
  end

  def descendants_via_nwc_optimized(user_id)
    Node.where("id in (
      WITH RECURSIVE nwc(orig_id, id, parent_id, rel_depth) AS (
        SELECT id, id, parent_id, 0
        FROM nodes
        WHERE id = ?
        UNION ALL
        SELECT np.orig_id, n.id, n.parent_id, np.rel_depth + 1
        FROM nwc np, nodes n
        WHERE np.id = n.parent_id
      ) SELECT id FROM nwc
    )", self.id)
  end

  def descendants_via_nwc2_arel(user_id)
    Node.where("id in (
      WITH RECURSIVE nwc(orig_id, id, parent_id, rel_depth) AS (
        SELECT id, id, parent_id, 0
        FROM nodes
        WHERE id = ?
        UNION ALL
        SELECT orig_id, n.id, n.parent_id, rel_depth + 1
        FROM nodes n
        INNER JOIN nwc ON nwc.id = n.parent_id
      ) SELECT id FROM nwc
    )", self.id)
  end

  def descendants_via_arel(user_id)
    self.class.find_by_sql(self.class.relatives_via_arel_mgr(false, id).to_sql)
  end

  def ancestors_via_arel(user_id)
    self.class.find_by_sql(self.class.relatives_via_arel_mgr(true, id).to_sql)
  end

  def node_system_tag_combos
  end

  def descendants_via_arel_with_visibility(user_id)
    hierarchy = Arel::Table.new :hierarchy
    recursive_table = Arel::Table.new(table_name).alias :recursive
    select_manager = Arel::SelectManager.new(ActiveRecord::Base).freeze

    non_recursive_term = select_manager.dup.tap do |m|
      m.from table_name
      m.project Arel.star
      m.where arel_table[:id].eq(id)
    end

    recursive_term = select_manager.dup.tap do |m|
      m.from recursive_table
      m.project recursive_table[Arel.star]
      m.join hierarchy
      m.on recursive_table[:parent_id].eq(hierarchy[:id])
    end

    union = non_recursive_term.union :all, recursive_term
    as_statement = Arel::Nodes::As.new hierarchy, union

    manager = select_manager.dup.tap do |m|
      m.with :recursive, as_statement
      m.from hierarchy
      m.project hierarchy[:id]
    end

    self.class.find_by_sql(manager.to_sql)
  end

  def descendants_via_arhq(user_id)
    _id = self.id
    Node.join_recursive do
      start_with(id: _id).
        connect_by(id: :parent_id)
    end
  end

  def ancestors_via_arhq(user_id)
    Node.join_recursive do |q|
      q.start_with(id: self.id)
        .connect_by(parent_id: :id)
    end
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

    def table
      arel_table
    end

    def relatives_via_arel_mgr(direction_towards_root, base_node_id = nil)
      hierarchy = Arel::Table.new :hierarchy
      recursive_table = Arel::Table.new(table_name).alias :recursive
      select_manager = Arel::SelectManager.new(ActiveRecord::Base).freeze

      non_recursive_term = select_manager.dup.tap do |m|
        m.from table_name
        m.project table[:id].as("base_id"), Arel.star
        unless base_node_id.nil?
          m.where arel_table[:id].eq(base_node_id)
        end
      end

      recursive_term = select_manager.dup.tap do |m|
        m.from recursive_table
        m.project hierarchy[:base_id], recursive_table[Arel.star]
        m.join hierarchy
        if direction_towards_root
          # take parent_id from results and match to id of node; add node to results
          m.on recursive_table[:id].eq(hierarchy[:parent_id])
        else
          m.on recursive_table[:parent_id].eq(hierarchy[:id])
        end
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
        .project(nwa[Arel::star], nstc[:td_tag], nstc[:ut_tag])
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
      n = table
      acp = Arel::Table.new :acp
      anar = Arel::Table.new :anar

      Arel::SelectManager.new
        .project(acp[:base_id], anar[:ut_tag].as("group_name"))
        .from(anar_closest_parent.as("acp"))
        .join(all_node_authz_reads.as("anar"))
        .on(anar[:id].eq(acp[:closest_permission_id]))
    end

    def old_nodes_readable_by(user_or_user_id)
      user = user_or_user_id.instance_of?(User) ? user_or_user_id : User.find(user_or_user_id)
      nar = Arel::Table.new :nar
      Arel::SelectManager.new
        .from(old_node_authz_read.as("nar"))
        .where(nar[:group_name].eq("all").or(nar[:group_name].in(user.groups_arel)))
        .project(nar[Arel.star])
    end

    def node_authz_read
      anar = Arel::Table.new :anar
      wpp = Arel::Table.new :wpp
      nwa = Arel::Table.new :nwa
      nstc = Arel::Table.new :nstc

      Arel::SelectManager.new
        .from(with_permissioned_parent.as("wpp"))
        .join(node_system_tag_combos.as("nstc"))
        .on(nstc[:id].eq(wpp[:closest_permission_id]))
        .where(nstc[:td_tag].eq(Authz.read))
        .project(wpp[Arel.star], nstc[:ut_tag].as("group_name"))
    end

    def nodes_readable_by(user_or_user_id)
      user = user_or_user_id.instance_of?(User) ? user_or_user_id : User.find(user_or_user_id)
      nar = Arel::Table.new :nar
      Arel::SelectManager.new
        .from(node_authz_read.as("nar"))
        .where(nar[:group_name].eq("all").or(nar[:group_name].in(user.groups_arel)))
        .project(nar[Arel.star])
    end

    def get_nodes_readable_by(user_or_id)
      find_by_sql nodes_readable_by(user_or_id)
    end

    def get_old_nodes_readable_by(user_or_id)
      find_by_sql old_nodes_readable_by(user_or_id)
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
