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

  create_table "authors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "name", size: :tiny
    t.bigint "user_id", null: false
    t.boolean "public", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "content_versions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "node_id"
    t.text "title"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_content_versions_on_author_id"
    t.index ["node_id"], name: "index_content_versions_on_node_id"
  end

  create_table "nodes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_nodes_on_author_id"
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
  end

  create_table "tag_decls", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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
    t.index ["target_id", "target_type"], name: "index_tag_decls_on_target_id_and_target_type"
    t.index ["target_type", "target_id"], name: "index_tag_decls_on_target"
    t.index ["user_id"], name: "index_tag_decls_on_user_id"
  end

  create_table "user_tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "tag", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag", "user_id"], name: "index_user_tags_on_tag_and_user_id"
    t.index ["tag"], name: "index_user_tags_on_tag"
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username", limit: 63, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "authors", "users"
  add_foreign_key "content_versions", "authors"
  add_foreign_key "content_versions", "nodes"
  add_foreign_key "nodes", "nodes", column: "parent_id"

  create_view "view_tag_decls", sql_definition: <<-SQL
      select `cff_dev2`.`tag_decls`.`id` AS `id`,`cff_dev2`.`tag_decls`.`anchored_type` AS `anchored_type`,`cff_dev2`.`tag_decls`.`anchored_id` AS `anchored_id`,`cff_dev2`.`tag_decls`.`target_type` AS `target_type`,`cff_dev2`.`tag_decls`.`target_id` AS `target_id`,`cff_dev2`.`tag_decls`.`tag` AS `tag`,`cff_dev2`.`tag_decls`.`user_id` AS `user_id`,`cff_dev2`.`tag_decls`.`created_at` AS `created_at`,`cff_dev2`.`tag_decls`.`updated_at` AS `updated_at` from `cff_dev2`.`tag_decls` where ((`cff_dev2`.`tag_decls`.`tag` = 'view') and (`cff_dev2`.`tag_decls`.`user_id` is null))
  SQL
  create_view "authz_tag_decls", sql_definition: <<-SQL
      select `cff_dev2`.`tag_decls`.`id` AS `id`,`cff_dev2`.`tag_decls`.`anchored_type` AS `anchored_type`,`cff_dev2`.`tag_decls`.`anchored_id` AS `anchored_id`,`cff_dev2`.`tag_decls`.`target_type` AS `target_type`,`cff_dev2`.`tag_decls`.`target_id` AS `target_id`,`cff_dev2`.`tag_decls`.`tag` AS `tag`,`cff_dev2`.`tag_decls`.`user_id` AS `user_id`,`cff_dev2`.`tag_decls`.`created_at` AS `created_at`,`cff_dev2`.`tag_decls`.`updated_at` AS `updated_at` from `cff_dev2`.`tag_decls` where ((`cff_dev2`.`tag_decls`.`tag` like 'authz_%') and (`cff_dev2`.`tag_decls`.`user_id` is null))
  SQL
  create_view "node_with_ancestors", sql_definition: <<-SQL
      with recursive `nwa` (`orig_id`,`id`,`parent_id`,`rel_height`) as (select `cff_dev2`.`nodes`.`id` AS `id`,`cff_dev2`.`nodes`.`id` AS `id`,`cff_dev2`.`nodes`.`parent_id` AS `parent_id`,0 AS `0` from `cff_dev2`.`nodes` union all select `np`.`orig_id` AS `orig_id`,`n`.`id` AS `id`,`n`.`parent_id` AS `parent_id`,(`np`.`rel_height` + 1) AS `np.rel_height + 1` from `nwa` `np` join `cff_dev2`.`nodes` `n` where (`np`.`parent_id` = `n`.`id`)) select `np`.`orig_id` AS `base_node_id`,`np`.`rel_height` AS `rel_height`,`n`.`id` AS `id`,`n`.`author_id` AS `author_id`,`n`.`parent_id` AS `parent_id`,`n`.`created_at` AS `created_at`,`n`.`updated_at` AS `updated_at` from `cff_dev2`.`nodes` `n` join `nwa` `np` where (`n`.`id` = `np`.`id`)
  SQL
  create_view "node_with_children", sql_definition: <<-SQL
      with recursive `nwc` (`orig_id`,`id`,`parent_id`,`rel_depth`) as (select `cff_dev2`.`nodes`.`id` AS `id`,`cff_dev2`.`nodes`.`id` AS `id`,`cff_dev2`.`nodes`.`parent_id` AS `parent_id`,0 AS `0` from `cff_dev2`.`nodes` union all select `np`.`orig_id` AS `orig_id`,`n`.`id` AS `id`,`n`.`parent_id` AS `parent_id`,(`np`.`rel_depth` + 1) AS `np.rel_depth + 1` from `nwc` `np` join `cff_dev2`.`nodes` `n` where (`np`.`id` = `n`.`parent_id`)) select `np`.`orig_id` AS `base_node_id`,`np`.`rel_depth` AS `rel_depth`,`n`.`id` AS `id`,`n`.`author_id` AS `author_id`,`n`.`parent_id` AS `parent_id`,`n`.`created_at` AS `created_at`,`n`.`updated_at` AS `updated_at` from `cff_dev2`.`nodes` `n` join `nwc` `np` where (`n`.`id` = `np`.`id`)
  SQL
  create_view "system_user_tags", sql_definition: <<-SQL
      select `ut`.`id` AS `id`,`ut`.`user_id` AS `user_id`,`ut`.`tag` AS `tag`,`ut`.`created_at` AS `created_at`,`ut`.`updated_at` AS `updated_at` from `cff_dev2`.`user_tags` `ut` where (`ut`.`user_id` is null)
  SQL
  create_view "system_tag_decls", sql_definition: <<-SQL
      select `td`.`id` AS `id`,`td`.`anchored_type` AS `anchored_type`,`td`.`anchored_id` AS `anchored_id`,`td`.`target_type` AS `target_type`,`td`.`target_id` AS `target_id`,`td`.`tag` AS `tag`,`td`.`user_id` AS `user_id`,`td`.`created_at` AS `created_at`,`td`.`updated_at` AS `updated_at` from `cff_dev2`.`tag_decls` `td` where (`td`.`user_id` is null)
  SQL
  create_view "user_groups", sql_definition: <<-SQL
      select `u`.`id` AS `user_id`,'all' AS `group_name` from `cff_dev2`.`users` `u` union all select NULL AS `NULL`,'all' AS `all` union all select `cff_dev2`.`td`.`anchored_id` AS `user_id`,`cff_dev2`.`ut`.`tag` AS `group_name` from ((`cff_dev2`.`system_tag_decls` `td` join `cff_dev2`.`system_user_tags` `ut` on((`cff_dev2`.`ut`.`id` = `cff_dev2`.`td`.`target_id`))) join `cff_dev2`.`users` `u` on((`cff_dev2`.`td`.`anchored_id` = `u`.`id`))) where ((1 = 1) and (`cff_dev2`.`td`.`anchored_type` = 'User') and (`cff_dev2`.`td`.`target_type` = 'UserTag'))
  SQL
  create_view "node_system_tag_combos", sql_definition: <<-SQL
      select `n`.`id` AS `node_id`,`cff_dev2`.`td`.`tag` AS `td_tag`,`cff_dev2`.`ut`.`tag` AS `ut_tag` from ((`cff_dev2`.`nodes` `n` join `cff_dev2`.`system_tag_decls` `td` on((`cff_dev2`.`td`.`anchored_id` = `n`.`id`))) join `cff_dev2`.`system_user_tags` `ut` on((`cff_dev2`.`td`.`target_id` = `cff_dev2`.`ut`.`id`))) where ((1 = 1) and (`cff_dev2`.`td`.`target_type` = 'UserTag') and (`cff_dev2`.`td`.`anchored_type` = 'Node'))
  SQL
  create_view "node_authz_reads", sql_definition: <<-SQL
      with `all_node_authz_read` as (select `cff_dev2`.`nwa`.`base_node_id` AS `base_node_id`,`cff_dev2`.`nwa`.`rel_height` AS `rel_height`,`cff_dev2`.`nstc`.`node_id` AS `node_id`,`cff_dev2`.`nstc`.`ut_tag` AS `group_name` from (`cff_dev2`.`node_with_ancestors` `nwa` join `cff_dev2`.`node_system_tag_combos` `nstc` on((`cff_dev2`.`nstc`.`node_id` = `cff_dev2`.`nwa`.`id`))) where (`cff_dev2`.`nstc`.`td_tag` = 'authz_read')), `rel_heights` as (select `all_node_authz_read`.`base_node_id` AS `base_node_id`,min(`all_node_authz_read`.`rel_height`) AS `height` from `all_node_authz_read` group by `all_node_authz_read`.`base_node_id`) select `anar`.`base_node_id` AS `base_node_id`,`anar`.`rel_height` AS `rel_height`,`anar`.`node_id` AS `authz_node_id`,`anar`.`group_name` AS `group_name` from (`all_node_authz_read` `anar` join `rel_heights` `rh` on((`anar`.`base_node_id` = `rh`.`base_node_id`))) where (`anar`.`rel_height` = `rh`.`height`)
  SQL
  create_view "nodes_user_sees", sql_definition: <<-SQL
      select `cff_dev2`.`nar`.`base_node_id` AS `base_node_id`,`cff_dev2`.`ug`.`user_id` AS `user_id` from (`cff_dev2`.`node_authz_reads` `nar` join `cff_dev2`.`user_groups` `ug` on((`cff_dev2`.`ug`.`group_name` = `cff_dev2`.`nar`.`group_name`)))
  SQL
end
