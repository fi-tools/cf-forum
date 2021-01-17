class CreateInit < ActiveRecord::Migration[6.1]
  def up
    # stand-in; replace later or alter as needed
    create_table :users do |t|
      # t.text :username, limit: 63, null: false
      # t.text :hex_pw_hash, null: false, limit: 63
      # t.text :email, unique: true, index: true
      t.string :username, limit: 63, null: false, unique: true, index: true
      t.timestamps
    end

    create_table :authors do |t|
      t.text :name, null: false, limit: 255
      t.belongs_to :user, null: false, foreign_key: true
      t.boolean :public, null: false, default: true

      t.timestamps
    end

    execute <<-SQL
      CREATE UNIQUE INDEX author_name_lower_index on authors (lower(name));
    SQL

    create_table :user_default_authors do |t|
      t.belongs_to :user, null: false, unique: true, foreign_key: true
      t.belongs_to :author, null: false, unique: true, foreign_key: true
    end

    create_table :content_versions do |t|
      t.belongs_to :author, foreign_key: true, index: true
      t.belongs_to :node, foreign_key: true, index: true
      # t.references :content_version, foreign_key: true, index: true, comment: "parent"
      t.text :title
      t.text :body

      t.timestamps
    end

    create_table :nodes do |t|
      t.belongs_to :author, index: true
      t.integer :parent_id, index: true
      t.timestamps
    end

    add_foreign_key :nodes, :nodes, column: :parent_id

    create_table :user_tags do |t|
      t.belongs_to :user, index: true
      t.string :tag, index: true, null: false
    end

    add_index :user_tags, [:tag, :user]

    create_table :tagged do |t|
      t.belongs_to :anchored, index: true, polymorphic: true
      t.belongs_to :target, index: true, polymorphic: true
      t.string :tag, index: true, null: false
      t.belongs_to :user, index: true
    end

    add_index :tagged, [:anchored_id, :anchored_type]
    add_index :tagged, [:target_id, :target_type]
    add_index :tagged, [:target_id, :target_type, :anchored_id, :anchored_type, :tag, :user], unique: true, name: "index_tagged_on_target_and_anchored_and_user"

    # execute "insert into content_versions (id, title, created_at, updated_at) values (0, 'Critical Fallibilism Forum', 0, 0)"
    # execute "insert into nodes (id, content_version_id, created_at, updated_at) values (0, 0, 0, 0)"
    # execute "update content_versions set node_id = 0 where id = 0"

    # execute "insert into content_versions (id, title, created_at, updated_at) values (1, 'Main', 0, 0)"
    # execute "insert into nodes (id, content_version_id, parent_id, created_at, updated_at) values (1, 1, 0, 0, 0)"
    # execute "update content_versions set node_id = 1 where id = 1"

    # create_table :node_links do |t|
    #   t.integer :from, foreign_key: true, index: true
    #   t.integer :to, foreign_key: true, index: true
    # end

    # add_foreign_key :node_links, :nodes, column: :from
    # add_foreign_key :node_links, :nodes, column: :to

    # create_table :tags do |t|
    #   t.text :name
    # end

    # create_table :tags_on_nodes do |t|
    #   t.belongs_to :tag, foreign_key: true, index: true
    #   t.belongs_to :node, foreign_key: true, index: true
    # end

    # create_table :tags_on_tags_on_nodes do |t|
    #   t.belongs_to :tag, foreign_key: true, index: true
    #   t.belongs_to :tags_on_node, foreign_key: true, index: true
    # end

    # create_table :tags_on_users do |t|
    #   t.belongs_to :tag, foreign_key: true, index: true
    #   t.belongs_to :user, foreign_key: true, index: true
    # end

    # create_table :tags_on_tags_on_users do |t|
    #   t.belongs_to :tag, foreign_key: true, index: true
    #   t.belongs_to :tags_on_user, foreign_key: true, index: true
    # end

    # todo: create_table :tags_on_links do |t|
    # todo: create_table :tags_on_tags_on_links do |t|
  end

  def down
    # drop_table :tags_on_tags_on_links
    # drop_table :tags_on_links
    # drop_table :tags_on_tags_on_users
    # drop_table :tags_on_users
    # drop_table :tags_on_tags_on_nodes
    # drop_table :tags_on_nodes
    # drop_table :tags
    # drop_table :node_links
    drop_table :nodes
    drop_table :content_versions
    drop_table :authors
    drop_table :users
  end
end
