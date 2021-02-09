class CreateNodeSystemTags < ActiveRecord::Migration[6.1]
  def change
    create_view :node_system_tags, materialized: true
    add_index :node_system_tags, [:node_id, :st_id], unique: true
  end
end
