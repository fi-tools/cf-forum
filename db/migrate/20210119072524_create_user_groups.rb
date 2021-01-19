class CreateUserGroups < ActiveRecord::Migration[6.1]
  def change
    create_view :user_groups
  end
end
