class CreateNodeAncestors < ActiveRecord::Migration[6.1]
  def change
    create_view :node_ancestors, materialized: true
    add_index :node_ancestors, [:base_id, :id, :distance], unique: true
    add_index :node_ancestors, [:id]
    add_index :node_ancestors, [:distance]
  end
end
