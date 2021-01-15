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

ActiveRecord::Schema.define(version: 2021_01_15_020047) do

  create_table "authors", force: :cascade do |t|
    t.text "name", limit: 255, null: false
    t.integer "user_id", null: false
    t.boolean "public?", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "content_versions", force: :cascade do |t|
    t.integer "author_id"
    t.integer "node_id"
    t.integer "content_version_id"
    t.text "title"
    t.text "body"
    t.text "body_diff"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_content_versions_on_author_id"
    t.index ["content_version_id"], name: "index_content_versions_on_content_version_id"
    t.index ["node_id"], name: "index_content_versions_on_node_id"
  end

  create_table "entries", force: :cascade do |t|
    t.string "meal_type"
    t.integer "calories"
    t.integer "proteins"
    t.integer "carbs"
    t.integer "fats"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "nodes", force: :cascade do |t|
    t.integer "author_id"
    t.integer "content_version_id"
    t.boolean "is_top_post"
    t.integer "parent_id"
    t.integer "genesis_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_nodes_on_author_id"
    t.index ["content_version_id"], name: "index_nodes_on_content_version_id"
    t.index ["genesis_id"], name: "index_nodes_on_genesis_id"
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "username", limit: 63, null: false
    t.text "hex_pw_hash", limit: 63, null: false
    t.text "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "authors", "users"
  add_foreign_key "content_versions", "authors"
  add_foreign_key "content_versions", "content_versions"
  add_foreign_key "content_versions", "nodes"
  add_foreign_key "nodes", "nodes", column: "genesis_id"
  add_foreign_key "nodes", "nodes", column: "parent_id"
end
