class CreateSystemUserTags < ActiveRecord::Migration[6.1]
  def change
    create_view :system_user_tags, materialized: true
  end
end
