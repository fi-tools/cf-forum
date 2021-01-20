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

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.text "name"
    t.bigint "user_id", null: false
    t.boolean "public", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "lower(name)", name: "index_authors_name_lower", unique: true
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "content_versions", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "node_id"
    t.text "title"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_content_versions_on_author_id"
    t.index ["node_id"], name: "index_content_versions_on_node_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.bigint "author_id"
    t.integer "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_nodes_on_author_id"
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
  end

  create_table "tag_decls", force: :cascade do |t|
    t.string "anchored_type"
    t.bigint "anchored_id"
    t.string "target_type"
    t.bigint "target_id"
    t.string "tag", null: false
    t.bigint "user_id"
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
    t.bigint "user_id", null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_user_default_authors_on_author_id"
    t.index ["user_id"], name: "index_user_default_authors_on_user_id"
  end

  create_table "user_tags", force: :cascade do |t|
    t.bigint "user_id"
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
    t.index "lower((email)::text)", name: "user_email_lower_index", unique: true
    t.index "lower((username)::text)", name: "index_users_username_lower", unique: true
    t.index "lower((username)::text)", name: "user_username_lower_index", unique: true
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
      SELECT tag_decls.id,
      tag_decls.anchored_type,
      tag_decls.anchored_id,
      tag_decls.target_type,
      tag_decls.target_id,
      tag_decls.tag,
      tag_decls.user_id,
      tag_decls.created_at,
      tag_decls.updated_at
     FROM tag_decls
    WHERE (((tag_decls.tag)::text = 'view'::text) AND (tag_decls.user_id IS NULL));
  SQL
  create_view "authz_tag_decls", sql_definition: <<-SQL
      SELECT tag_decls.id,
      tag_decls.anchored_type,
      tag_decls.anchored_id,
      tag_decls.target_type,
      tag_decls.target_id,
      tag_decls.tag,
      tag_decls.user_id,
      tag_decls.created_at,
      tag_decls.updated_at
     FROM tag_decls
    WHERE (((tag_decls.tag)::text ~~ 'authz_%'::text) AND (tag_decls.user_id IS NULL));
  SQL
  create_view "node_with_ancestors", materialized: true, sql_definition: <<-SQL
      WITH RECURSIVE nwa(orig_id, id, parent_id, rel_height) AS (
           SELECT nodes.id,
              nodes.id,
              nodes.parent_id,
              0
             FROM nodes
          UNION ALL
           SELECT np_1.orig_id,
              n_1.id,
              n_1.parent_id,
              (np_1.rel_height + 1)
             FROM nwa np_1,
              nodes n_1
            WHERE (np_1.parent_id = n_1.id)
          )
   SELECT np.orig_id AS base_node_id,
      np.rel_height,
      n.id,
      n.author_id,
      n.parent_id,
      n.created_at,
      n.updated_at
     FROM nodes n,
      nwa np
    WHERE (n.id = np.id);
  SQL
  add_index "node_with_ancestors", ["base_node_id", "rel_height"], name: "index_node_with_ancestors_on_base_node_id_and_rel_height", unique: true
  add_index "node_with_ancestors", ["id"], name: "index_node_with_ancestors_on_id"

  create_view "node_with_children", materialized: true, sql_definition: <<-SQL
      WITH RECURSIVE nwc(orig_id, id, parent_id, rel_depth) AS (
           SELECT nodes.id,
              nodes.id,
              nodes.parent_id,
              0
             FROM nodes
          UNION ALL
           SELECT np_1.orig_id,
              n_1.id,
              n_1.parent_id,
              (np_1.rel_depth + 1)
             FROM nwc np_1,
              nodes n_1
            WHERE (np_1.id = n_1.parent_id)
          )
   SELECT np.orig_id AS base_node_id,
      np.rel_depth,
      n.id,
      n.author_id,
      n.parent_id,
      n.created_at,
      n.updated_at
     FROM nodes n,
      nwc np
    WHERE (n.id = np.id);
  SQL
  add_index "node_with_children", ["base_node_id", "rel_depth"], name: "index_node_with_children_on_base_node_id_and_rel_depth", unique: true
  add_index "node_with_children", ["id"], name: "index_node_with_children_on_id"

  create_view "system_user_tags", materialized: true, sql_definition: <<-SQL
      SELECT ut.id,
      ut.user_id,
      ut.tag,
      ut.created_at,
      ut.updated_at
     FROM user_tags ut
    WHERE (ut.user_id IS NULL);
  SQL
  create_view "system_tag_decls", materialized: true, sql_definition: <<-SQL
      SELECT td.id,
      td.anchored_type,
      td.anchored_id,
      td.target_type,
      td.target_id,
      td.tag,
      td.user_id,
      td.created_at,
      td.updated_at
     FROM tag_decls td
    WHERE (td.user_id IS NULL);
  SQL
  create_view "user_groups", materialized: true, sql_definition: <<-SQL
      SELECT u.id AS user_id,
      'all'::text AS group_name
     FROM users u
  UNION ALL
   SELECT NULL::bigint AS user_id,
      'all'::text AS group_name
  UNION ALL
   SELECT td.anchored_id AS user_id,
      ut.tag AS group_name
     FROM ((system_tag_decls td
       JOIN system_user_tags ut ON ((ut.id = td.target_id)))
       JOIN users u ON ((td.anchored_id = u.id)))
    WHERE ((1 = 1) AND ((td.anchored_type)::text = 'User'::text) AND ((td.target_type)::text = 'UserTag'::text));
  SQL
  create_view "node_system_tag_combos", materialized: true, sql_definition: <<-SQL
      SELECT n.id AS node_id,
      td.tag AS td_tag,
      ut.tag AS ut_tag
     FROM ((nodes n
       JOIN system_tag_decls td ON ((td.anchored_id = n.id)))
       JOIN system_user_tags ut ON ((td.target_id = ut.id)))
    WHERE ((1 = 1) AND ((td.target_type)::text = 'UserTag'::text) AND ((td.anchored_type)::text = 'Node'::text));
  SQL
  add_index "node_system_tag_combos", ["node_id", "td_tag"], name: "index_node_system_tag_combos_on_node_id_and_td_tag", unique: true
  add_index "node_system_tag_combos", ["node_id"], name: "index_node_system_tag_combos_on_node_id", unique: true
  add_index "node_system_tag_combos", ["td_tag"], name: "index_node_system_tag_combos_on_td_tag", unique: true

  create_view "node_authz_reads", materialized: true, sql_definition: <<-SQL
      WITH all_node_authz_read AS (
           SELECT nwa.base_node_id,
              nwa.rel_height,
              nstc.node_id,
              nstc.ut_tag AS group_name
             FROM (node_with_ancestors nwa
               JOIN node_system_tag_combos nstc ON ((nstc.node_id = nwa.id)))
            WHERE ((nstc.td_tag)::text = 'authz_read'::text)
          ), rel_heights AS (
           SELECT all_node_authz_read.base_node_id,
              min(all_node_authz_read.rel_height) AS height
             FROM all_node_authz_read
            GROUP BY all_node_authz_read.base_node_id
          )
   SELECT anar.base_node_id,
      anar.rel_height,
      anar.node_id AS authz_node_id,
      anar.group_name
     FROM (all_node_authz_read anar
       JOIN rel_heights rh ON ((anar.base_node_id = rh.base_node_id)))
    WHERE (anar.rel_height = rh.height);
  SQL
  create_view "nodes_user_sees", materialized: true, sql_definition: <<-SQL
      SELECT nar.base_node_id,
      ug.user_id
     FROM (node_authz_reads nar
       JOIN user_groups ug ON ((ug.group_name = (nar.group_name)::text)));
  SQL
  add_index "nodes_user_sees", ["base_node_id"], name: "index_nodes_user_sees_on_base_node_id"
  add_index "nodes_user_sees", ["user_id"], name: "index_nodes_user_sees_on_user_id"

end
