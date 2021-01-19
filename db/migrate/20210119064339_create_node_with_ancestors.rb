class CreateNodeWithAncestors < ActiveRecord::Migration[6.1]
  def change
    create_view :node_with_ancestors
  end
end
