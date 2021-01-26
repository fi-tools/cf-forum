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

ActiveRecord::Schema.define(version: 2021_01_26_082339) do

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
    t.bigint "parent_id"
    t.bigint "depth", default: 0
    t.bigint "n_children", default: 0
    t.bigint "n_descendants", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_nodes_on_author_id"
    t.index ["depth"], name: "index_nodes_on_depth"
    t.index ["n_children"], name: "index_nodes_on_n_children"
    t.index ["n_descendants"], name: "index_nodes_on_n_descendants"
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
    t.index ["anchored_type", "anchored_id"], name: "index_tag_decls_on_anchored"
    t.index ["anchored_type"], name: "index_tag_decls_on_anchored_type"
    t.index ["tag"], name: "index_tag_decls_on_tag"
    t.index ["target_id", "target_type", "anchored_id", "anchored_type", "tag", "user_id"], name: "index_tagged_on_target_and_anchored_and_user", unique: true
    t.index ["target_type", "target_id"], name: "index_tag_decls_on_target"
    t.index ["target_type"], name: "index_tag_decls_on_target_type"
    t.index ["user_id"], name: "index_tag_decls_on_user_id"
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

  create_view "system_tags", materialized: true, sql_definition: <<-SQL
      SELECT td.id,
      td.tag AS td_tag,
      td.anchored_type,
      td.anchored_id,
      ut.tag AS ut_tag
     FROM (tag_decls td
       JOIN user_tags ut ON ((td.target_id = ut.id)))
    WHERE (((td.target_type)::text = 'UserTag'::text) AND (ut.user_id IS NULL) AND (td.user_id IS NULL));
  SQL
  add_index "system_tags", ["id"], name: "index_system_tags_on_id", unique: true

  create_view "node_system_tags", materialized: true, sql_definition: <<-SQL
      SELECT nodes.id AS node_id,
      st.id AS st_id,
      st.td_tag,
      st.ut_tag
     FROM (nodes
       JOIN system_tags st ON ((nodes.id = st.anchored_id)))
    WHERE ((st.anchored_type)::text = 'Node'::text);
  SQL
  add_index "node_system_tags", ["node_id", "st_id"], name: "index_node_system_tags_on_node_id_and_st_id", unique: true

  create_view "node_ancestors", materialized: true, sql_definition: <<-SQL
      WITH RECURSIVE hierarchy AS (
           SELECT nodes.id AS base_id,
              nodes.id,
              nodes.parent_id,
              0 AS distance
             FROM nodes
          UNION ALL
           SELECT hierarchy_1.base_id,
              recursive.id,
              recursive.parent_id,
              (hierarchy_1.distance + 1)
             FROM (nodes recursive
               JOIN hierarchy hierarchy_1 ON ((recursive.id = hierarchy_1.parent_id)))
          )
   SELECT hierarchy.base_id,
      hierarchy.id,
      hierarchy.parent_id,
      hierarchy.distance
     FROM hierarchy;
  SQL
  add_index "node_ancestors", ["base_id", "id", "distance"], name: "index_node_ancestors_on_base_id_and_id_and_distance", unique: true
  add_index "node_ancestors", ["distance"], name: "index_node_ancestors_on_distance"
  add_index "node_ancestors", ["id"], name: "index_node_ancestors_on_id"

  create_view "node_descendants", materialized: true, sql_definition: <<-SQL
      WITH RECURSIVE hierarchy AS (
           SELECT nodes.id AS base_id,
              nodes.id,
              nodes.parent_id,
              0 AS distance
             FROM nodes
          UNION ALL
           SELECT hierarchy_1.base_id,
              recursive.id,
              recursive.parent_id,
              (hierarchy_1.distance + 1)
             FROM (nodes recursive
               JOIN hierarchy hierarchy_1 ON ((recursive.parent_id = hierarchy_1.id)))
          )
   SELECT hierarchy.base_id,
      hierarchy.id,
      hierarchy.parent_id,
      hierarchy.distance
     FROM hierarchy;
  SQL
  add_index "node_descendants", ["base_id", "id", "distance"], name: "index_node_descendants_on_base_id_and_id_and_distance", unique: true
  add_index "node_descendants", ["distance"], name: "index_node_descendants_on_distance"
  add_index "node_descendants", ["id"], name: "index_node_descendants_on_id"

  create_view "node_inherited_authz_reads", materialized: true, sql_definition: <<-SQL
      WITH node_all_ancestor_authz(base_id, id, groups) AS (
           SELECT na.base_id,
              na.id,
              array_agg(nst.ut_tag) AS groups
             FROM (node_ancestors na
               JOIN node_system_tags nst ON ((na.id = nst.node_id)))
            WHERE ((nst.td_tag)::text = 'authz_read'::text)
            GROUP BY na.base_id, na.id
          ), closest_parent(base_id, closest_ancestor_id) AS (
           SELECT node_all_ancestor_authz.base_id,
              max(node_all_ancestor_authz.id) AS closest_ancestor_id
             FROM node_all_ancestor_authz
            GROUP BY node_all_ancestor_authz.base_id
          ), node_to_permissions(node_id, groups) AS (
           SELECT naaa.base_id,
              naaa.groups
             FROM (node_all_ancestor_authz naaa
               JOIN closest_parent cp ON (((cp.base_id = naaa.base_id) AND (cp.closest_ancestor_id = naaa.id))))
          )
   SELECT node_to_permissions.node_id,
      node_to_permissions.groups
     FROM node_to_permissions;
  SQL
  add_index "node_inherited_authz_reads", ["node_id"], name: "index_node_inherited_authz_reads_on_node_id", unique: true

  create_view "users_groups", materialized: true, sql_definition: <<-SQL
      WITH raw_groups AS (
           SELECT u.id AS user_id,
              st.ut_tag
             FROM (users u
               JOIN system_tags st ON ((st.anchored_id = u.id)))
            WHERE ((st.anchored_type)::text = 'User'::text)
          UNION ALL
           SELECT u.id AS user_id,
              'all'::character varying AS ut_tag
             FROM users u
          UNION ALL
           SELECT NULL::bigint,
              'all'::character varying
          )
   SELECT raw_groups.user_id,
      array_agg(raw_groups.ut_tag) AS groups
     FROM raw_groups
    GROUP BY raw_groups.user_id;
  SQL
  add_index "users_groups", ["user_id"], name: "index_users_groups_on_user_id", unique: true

  create_view "nodes_readables", sql_definition: <<-SQL
      SELECT niar.node_id,
      ug.user_id,
      niar.groups AS node_groups,
      ug.groups AS user_groups
     FROM (node_inherited_authz_reads niar
       JOIN users_groups ug ON ((niar.groups && ug.groups)));
  SQL
  create_trigger("nodes_after_insert_row_tr", :compatibility => 1).
      on("nodes").
      after(:insert) do
    <<-SQL_ACTIONS

      --with parent_depth as (select n2.depth FROM nodes n2 WHERE n2.id = NEW.parent_id)
      UPDATE nodes n
      SET depth = (select n2.depth FROM nodes n2 WHERE n2.id = NEW.parent_id) + 1
      WHERE n.id = NEW.id AND NEW.parent_id IS NOT NULL;

      UPDATE nodes n
      SET n_children = n.n_children + 1
      WHERE n.id = NEW.parent_id;

      with recursive ancestors as (
        select id, parent_id
        from nodes
        where id = NEW.parent_id
        union all
        select ns.id, ns.parent_id
        from nodes ns
        inner join ancestors a
          on a.parent_id = ns.id
      )
      UPDATE nodes n
      SET n_descendants = n.n_descendants + 1
      where id in (
        select id from ancestors
      );
    SQL_ACTIONS
  end

end
