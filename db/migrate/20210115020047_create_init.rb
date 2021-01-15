class CreateInit < ActiveRecord::Migration[6.1]
  def change
    # stand-in; replace later or alter as needed
    create_table :users do |t|
      t.text :username, limit: 63, null: false
      t.text :hex_pw_hash, null: false, limit: 63
      t.text :email, unique: true, index: true

      t.timestamps
    end

    create_table :authors do |t|
      t.text :name, null: false, limit: 255
      t.belongs_to :user, null: false, foreign_key: true
      t.boolean :public?, null: false

      t.timestamps
    end

    create_table :content_versions do |t|
      t.belongs_to :author, foreign_key: true, index: true
      t.belongs_to :node, foreign_key: true, index: true
      t.references :content_version, foreign_key: true, index: true, comment: "parent"
      t.text :title
      t.text :body
      t.text :body_diff
      
      t.timestamps
    end

    create_table :nodes do |t|
      t.belongs_to :author
      t.belongs_to :content_version
      t.boolean :is_top_post

      t.integer :parent_id, index: true
      t.integer :genesis_id, index: true

      t.timestamps
    end

    add_foreign_key :nodes, :nodes, column: :parent_id
    add_foreign_key :nodes, :nodes, column: :genesis_id

  end
end
