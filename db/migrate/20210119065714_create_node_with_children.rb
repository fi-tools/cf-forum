class CreateNodeWithChildren < ActiveRecord::Migration[6.1]
  def change
    create_view :node_with_children, materialized: true
  end
end
