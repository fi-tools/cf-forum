class CreateNodesUserSees < ActiveRecord::Migration[6.1]
  def change
    create_view :nodes_user_sees
  end
end
