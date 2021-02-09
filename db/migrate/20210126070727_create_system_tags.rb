class CreateSystemTags < ActiveRecord::Migration[6.1]
  def change
    create_view :system_tags, materialized: true
    add_index :system_tags, :id, unique: true
  end
end
