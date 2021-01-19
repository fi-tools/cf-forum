class AddViewIndexes < ActiveRecord::Migration[6.1]
  def change
    
    unless ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::SQLite3Adapter
      # hmm, in sqlite: indexes aren't supported on views
      add_index :node_with_ancestors, [:base_node_id, :rel_height], unique: true
      add_index :node_with_ancestors, [:id]
      add_index :node_with_children, [:base_node_id, :rel_height], unique: true
      add_index :node_with_children, [:id]
      add_index :node_system_tag_combos, [:node_id], unique: true
      add_index :node_system_tag_combos, [:node_id, :td_tag], unique: true
      add_index :node_system_tag_combos, [:td_tag], unique: true
      add_index :nodes_user_sees, [:base_id_node]
      add_index :nodes_user_sees, [:user_id]
    end
  end
end
