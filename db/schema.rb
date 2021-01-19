# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_19_134716) do

  create_table "authors", force: :cascade do |t|
    t.text "name", limit: 255
    t.integer "user_id", null: false
    t.boolean "public", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "lower(name)", name: "index_authors_name_lower", unique: true
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "content_versions", force: :cascade do |t|
    t.integer "author_id"
    t.integer "node_id"
    t.text "title"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_content_versions_on_author_id"
    t.index ["node_id"], name: "index_content_versions_on_node_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.integer "author_id"
    t.integer "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_nodes_on_author_id"
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
  end

  create_table "tag_decls", force: :cascade do |t|
    t.string "anchored_type"
    t.integer "anchored_id"
    t.string "target_type"
    t.integer "target_id"
    t.string "tag", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["anchored_id", "anchored_type"], name: "index_tag_decls_on_anchored_id_and_anchored_type"
    t.index ["anchored_type", "anchored_id"], name: "index_tag_decls_on_anchored"
    t.index ["tag"], name: "index_tag_decls_on_tag"
    t.index ["target_id", "target_type", "anchored_id", "anchored_type", "tag", "user_id"], name: "index_tagged_on_target_and_anchored_and_user", unique: true
    t.index ["target_id", "target_type"], name: "index_tag_decls_on_target_id_and_target_type"
    t.index ["target_type", "target_id"], name: "index_tag_decls_on_target"
    t.index ["user_id"], name: "index_tag_decls_on_user_id"
  end

  create_table "user_default_authors", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "author_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_user_default_authors_on_author_id"
    t.index ["user_id"], name: "index_user_default_authors_on_user_id"
  end

  create_table "user_tags", force: :cascade do |t|
    t.integer "user_id"
    t.string "tag", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag", "user_id"], name: "index_user_tags_on_tag_and_user_id"
    t.index ["tag"], name: "index_user_tags_on_tag"
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 63, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index "lower(email)", name: "user_email_lower_index", unique: true
    t.index "lower(username)", name: "index_users_username_lower", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "authors", "users"
  add_foreign_key "content_versions", "authors"
  add_foreign_key "content_versions", "nodes"
  add_foreign_key "nodes", "nodes", column: "parent_id"
  add_foreign_key "user_default_authors", "authors"
  add_foreign_key "user_default_authors", "users"

  create_view "view_tag_decls", sql_definition: <<-SQL
      -- the user_id here belongs to the person who created the tag declaration.
  -- since were using tags created by the system, the user_id is null.

  SELECT * FROM tag_decls WHERE tag = 'view' AND user_id IS NULL
  SQL
  create_view "authz_tag_decls", sql_definition: <<-SQL
      -- the user_id here belongs to the person who created the tag declaration.
  -- since were using tags created by the system, the user_id is null.

  SELECT * FROM tag_decls WHERE tag LIKE 'authz_%' AND user_id IS NULL
  SQL
  create_view "node_with_ancestors", sql_definition: <<-SQL
      WITH RECURSIVE nwa(orig_id, id, parent_id, rel_height) AS (
          SELECT id, id, parent_id, 0
          FROM nodes
          UNION ALL
          SELECT np.orig_id, n.id, n.parent_id, np.rel_height + 1
          FROM nwa np, nodes n
          WHERE np.parent_id = n.id
  ) SELECT np.orig_id as base_node_id, np.rel_height, n.* FROM nodes n, nwa np WHERE n.id = np.id
  SQL
  create_view "node_with_children", sql_definition: <<-SQL
      WITH RECURSIVE nwc(orig_id, id, parent_id, rel_depth) AS (
          SELECT id, id, parent_id, 0
          FROM nodes
          UNION ALL
          SELECT np.orig_id, n.id, n.parent_id, np.rel_depth + 1
          FROM nwc np, nodes n
          WHERE np.id = n.parent_id
  ) SELECT np.orig_id as base_node_id, np.rel_depth, n.* FROM nodes n, nwc np WHERE n.id = np.id
  SQL
  create_view "user_groups", sql_definition: <<-SQL
      -- everyone is part of 'all'
  --SELECT IFNULL(user_id,'null') || '|' || group_name as id, * from ( 
      SELECT u.id as user_id, 'all' as group_name FROM users u

      UNION ALL

      SELECT NULL, 'all'

      UNION ALL

      SELECT td.anchored_id as user_id, ut.tag as group_name
      FROM system_tag_decls td, users u
      JOIN system_user_tags ut ON td.target_id = ut.id
      WHERE 1
          AND td.anchored_type = 'User'
          AND td.target_type = 'UserTag'
          AND td.anchored_id = u.id
  --)
  SQL
  create_view "system_user_tags", sql_definition: <<-SQL
      SELECT ut.*
  FROM user_tags ut
  WHERE ut.user_id IS NULL
  SQL
  create_view "system_tag_decls", sql_definition: <<-SQL
      SELECT td.*
  FROM tag_decls td
  WHERE td.user_id IS NULL
  SQL
  create_view "node_system_tag_combos", sql_definition: <<-SQL
      SELECT n.id as node_id, td.tag as td_tag, ut.tag as ut_tag
  FROM nodes n
  JOIN system_tag_decls td ON td.anchored_id = n.id
  JOIN system_user_tags ut ON td.target_id = ut.id
  WHERE 1
      AND td.target_type = 'UserTag'
      AND td.anchored_type = 'Node'
  SQL
  create_view "node_authz_reads", sql_definition: <<-SQL
      WITH all_node_authz_read AS (
      SELECT nwa.base_node_id, nwa.rel_height, nstc.node_id, nstc.ut_tag as group_name
  FROM node_with_ancestors nwa
  JOIN node_system_tag_combos as nstc ON nstc.node_id = nwa.id
  WHERE nstc.td_tag = 'authz_read'
  ),
  rel_heights AS (
      SELECT base_node_id, MIN(rel_height) AS height
      FROM all_node_authz_read
      GROUP BY base_node_id
  )
  SELECT anar.base_node_id, anar.rel_height, anar.node_id as authz_node_id, anar.group_name
  FROM all_node_authz_read anar
  JOIN rel_heights rh ON anar.base_node_id = rh.base_node_id
  WHERE anar.rel_height = rh.height
  SQL
  create_view "nodes_user_sees", sql_definition: <<-SQL
      SELECT nar.base_node_id, user_id
  FROM node_authz_reads nar
  JOIN user_groups ug ON ug.group_name = nar.group_name
  SQL
end
