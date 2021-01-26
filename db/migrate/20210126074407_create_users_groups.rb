class CreateUsersGroups < ActiveRecord::Migration[6.1]
  def change
    create_view :users_groups, materialized: true
    add_index :users_groups, :user_id, unique: true
  end
end
