class CreateNodesReadables < ActiveRecord::Migration[6.1]
  def change
    create_view :nodes_readables
    # not materialized so don't create an index
    # add_index :nodes_readables, [:node_id, :user_id], unique: true
  end
end
