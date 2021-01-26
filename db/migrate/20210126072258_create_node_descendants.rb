class CreateNodeDescendants < ActiveRecord::Migration[6.1]
  def change
    create_view :node_descendants, materialized: true
  end
end
