class AddViewIndexes < ActiveRecord::Migration[6.1]
  def change
    
    # alt method of checking: ActiveRecord::Base.connection.adapter_name == 'MySQL'
    # unless ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::SQLite3Adapter
    puts ActiveRecord::Base.connection.adapter_name, '^^^ -- ActiveRecord::Base.connection.adapter_name'
    # for the moment disable this for postgres too -- had issues with materialized views
    unless ['SQLite', 'PostgreSQL'].include? ActiveRecord::Base.connection.adapter_name
      # hmm, in sqlite: indexes aren't supported on views
      add_index :node_with_ancestors, [:base_node_id, :rel_height], unique: true
      add_index :node_with_ancestors, [:id]
      add_index :node_with_children, [:base_node_id, :rel_depth], unique: true
      add_index :node_with_children, [:id]
      add_index :node_system_tag_combos, [:node_id], unique: true
      add_index :node_system_tag_combos, [:node_id, :td_tag], unique: true
      add_index :node_system_tag_combos, [:td_tag], unique: true
      add_index :nodes_user_sees, [:base_node_id]
      add_index :nodes_user_sees, [:user_id]
    end
  end
end
