class CreateInit < ActiveRecord::Migration[6.1]
  def up
    # stand-in; replace later or alter as needed
    create_table :users do |t|
      t.string :username, limit: 63, null: false, unique: true, index: true
      t.timestamps
    end

    create_table :authors do |t|
      t.text :name, limit: 255
      t.belongs_to :user, null: false, foreign_key: true
      t.boolean :public, null: false, default: true

      t.timestamps
    end

    unless ActiveRecord::Base.connection.adapter_name == "Mysql2"
      execute <<-SQL
        CREATE UNIQUE INDEX index_users_username_lower on users (lower(username));
        CREATE UNIQUE INDEX index_authors_name_lower on authors (lower(name));
      SQL
    end

    # Note: not using this atm and the foreign key constraint causes an issue testing mysql
    # create_table :user_default_authors do |t|
    #   t.belongs_to :user, null: false, unique: true, foreign_key: true
    #   t.belongs_to :author, null: false, unique: true, foreign_key: true
    #   t.timestamps
    # end

    create_table :node_ancestors_incrs do |t|
      t.bigint :base_id, index: true
      t.bigint :node_id
      t.bigint :distance
    end

    create_table :node_descendants_incrs do |t|
      t.bigint :base_id, index: true
      t.bigint :node_id
      t.bigint :distance
    end

    add_index :node_descendants_incrs, [:base_id, :node_id]
    add_index :node_descendants_incrs, [:node_id, :base_id]

    create_table :nodes do |t|
      t.belongs_to :author, index: true
      t.bigint :parent_id, index: true
      t.bigint :depth, index: true, default: 0
      t.bigint :n_children, index: true, default: 0
      t.bigint :n_descendants, index: true, default: 0
      t.timestamps
    end

    create_trigger(:compatibility => 1).on(:nodes).after(:insert) do
      <<-SQL
      --with parent_depth as (select n2.depth FROM nodes n2 WHERE n2.id = NEW.parent_id)
      UPDATE nodes n
      SET depth = (select n2.depth FROM nodes n2 WHERE n2.id = NEW.parent_id) + 1
      WHERE n.id = NEW.id AND NEW.parent_id IS NOT NULL;

      UPDATE nodes n
      SET n_children = n.n_children + 1
      WHERE n.id = NEW.parent_id;

      -- start with distance=1 bc we start with the parent node, not the NEW node
      with recursive ancestors(base_id, id, parent_id, distance) as (
        select NEW.id as base_id, id, parent_id, 0 as distance
        from nodes
        where id = NEW.id
        union all
        select a.base_id, ns.id, ns.parent_id, a.distance + 1
        from nodes ns
        inner join ancestors a
          on a.parent_id = ns.id
      ),

      -- updating n_descendants used to be here; but we need some final query
      -- or have to use PERFORM or something
      --dec_update as (
      --),

      -- build ancestors incrementally
      anc_incr as (INSERT INTO node_ancestors_incrs (base_id, node_id, distance)
      SELECT base_id, id, distance
      from ancestors RETURNING 1)

      ---- build descendants incrementally
      --dec_incr as (INSERT INTO node_descendants_incrs (base_id, node_id, distance)
      --SELECT id, base_id, distance
      --FROM ancestors RETURNING 1)

      -- cache n_descendants
      UPDATE nodes n
      SET n_descendants = n.n_descendants + 1
      where id in (
        select id from ancestors
      ) and id != NEW.id;
      --and 1 in (select * from anc_incr union all select * from dec_incr);

      SQL
    end
    add_foreign_key :nodes, :nodes, column: :parent_id
    add_foreign_key :node_descendants_incrs, :nodes, column: :node_id
    add_foreign_key :node_descendants_incrs, :nodes, column: :base_id
    add_foreign_key :node_ancestors_incrs, :nodes, column: :node_id
    add_foreign_key :node_ancestors_incrs, :nodes, column: :base_id

    create_table :content_versions do |t|
      t.belongs_to :author, foreign_key: true, index: true
      t.belongs_to :node, foreign_key: true, index: true
      # t.references :content_version, foreign_key: true, index: true, comment: "parent"
      t.text :title
      t.text :body

      t.timestamps
    end

    create_table :user_tags do |t|
      t.belongs_to :user, index: true
      t.string :tag, index: true, null: false
      t.timestamps
    end

    # todo: is this redundant?
    add_index :user_tags, [:tag, :user_id]

    create_table :tag_decls do |t|
      t.belongs_to :anchored, index: true, polymorphic: true
      t.belongs_to :target, index: true, polymorphic: true
      t.string :tag, index: true, null: false
      t.belongs_to :user, index: true
      t.timestamps
    end

    add_index :tag_decls, [:anchored_type]
    add_index :tag_decls, [:target_type]

    unless ActiveRecord::Base.connection.adapter_name == "Mysql2"
      # mysql complains `Mysql2::Error: Specified key was too long; max key length is 3072 bytes`
      add_index :tag_decls, [:target_id, :target_type, :anchored_id, :anchored_type, :tag, :user_id], unique: true, name: "index_tagged_on_target_and_anchored_and_user"
    end
  end

  def down
    drop_table :tag_decls
    drop_table :user_tags
    drop_table :nodes
    drop_table :content_versions
    drop_table :authors
    drop_table :users
  end
end
