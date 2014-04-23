# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140423133924) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
    t.integer  "work_id"
  end

  add_index "categories", ["work_id"], name: "index_categories_on_work_id"

  create_table "link_collections", force: true do |t|
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "depth"
    t.integer  "work_id"
  end

  add_index "link_collections", ["node_id"], name: "index_link_collections_on_node_id"
  add_index "link_collections", ["work_id"], name: "index_link_collections_on_work_id"

  create_table "links", force: true do |t|
    t.integer  "child_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "work_id"
    t.integer  "link_collection_id"
  end

  add_index "links", ["child_id"], name: "index_links_on_child_id"
  add_index "links", ["link_collection_id"], name: "index_links_on_link_collection_id"
  add_index "links", ["parent_id"], name: "index_links_on_parent_id"

  create_table "nodes", force: true do |t|
    t.string   "title"
    t.integer  "category_id"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.text     "combined_notes", default: ""
    t.integer  "depth"
  end

  add_index "nodes", ["category_id"], name: "index_nodes_on_category_id"
  add_index "nodes", ["work_id"], name: "index_nodes_on_work_id"

  create_table "notes", force: true do |t|
    t.integer  "node_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "depth"
  end

  add_index "notes", ["node_id"], name: "index_notes_on_node_id"

  create_table "place_holders", force: true do |t|
    t.integer  "work_id"
    t.string   "text"
    t.integer  "depth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "place_holders", ["work_id"], name: "index_place_holders_on_work_id"

  create_table "positions", force: true do |t|
    t.integer  "x"
    t.integer  "y"
    t.integer  "size"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "positions", ["node_id"], name: "index_positions_on_node_id"

  create_table "stacks", force: true do |t|
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "work_groups", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "work_groups", ["user_id"], name: "index_work_groups_on_user_id"

  create_table "works", force: true do |t|
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "order"
    t.boolean  "show_others"
  end

  add_index "works", ["group_id"], name: "index_works_on_group_id"

end
