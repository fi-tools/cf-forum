class AddGetNodeDescendantsF < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE FUNCTION get_node_descendants(node_id bigint)
      RETURNS TABLE (id bigint) 
      SET SCHEMA 'public'
      language sql as $$
          WITH RECURSIVE search_tree(p_id) AS (
              SELECT nodes.id
              FROM nodes
              WHERE nodes.id = (node_id)
              UNION ALL
              SELECT id
              FROM search_tree, nodes o
              WHERE search_tree.p_id = o.parent_id
          )
          SELECT * from search_tree;
        $$
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS get_node_descendants
    SQL
  end
end
