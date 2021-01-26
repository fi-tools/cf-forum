class CreateNodeAncestors < ActiveRecord::Migration[6.1]
  def change
    create_view :node_ancestors, materialized: true
  end
end
