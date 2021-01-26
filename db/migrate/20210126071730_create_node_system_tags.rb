class CreateNodeSystemTags < ActiveRecord::Migration[6.1]
  def change
    create_view :node_system_tags, materialized: true
  end
end
