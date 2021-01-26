class CreateUserGroups < ActiveRecord::Migration[6.1]
  def change
    create_view :users_groups, materialized: true
  end
end
