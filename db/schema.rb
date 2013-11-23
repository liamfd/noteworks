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

ActiveRecord::Schema.define(version: 20131123173758) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", force: true do |t|
    t.string   "title"
    t.integer  "category_id"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "nodes", ["category_id"], name: "index_nodes_on_category_id"
  add_index "nodes", ["work_id"], name: "index_nodes_on_work_id"

  create_table "notes", force: true do |t|
    t.integer  "node_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["node_id"], name: "index_notes_on_node_id"

  create_table "parent_children", force: true do |t|
    t.integer  "child_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parent_children", ["child_id"], name: "index_parent_children_on_child_id"
  add_index "parent_children", ["parent_id"], name: "index_parent_children_on_parent_id"

  create_table "positions", force: true do |t|
    t.integer  "x"
    t.integer  "y"
    t.integer  "size"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "positions", ["node_id"], name: "index_positions_on_node_id"

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
  end

  add_index "work_groups", ["user_id"], name: "index_work_groups_on_user_id"

  create_table "works", force: true do |t|
    t.text     "markup"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "works", ["group_id"], name: "index_works_on_group_id"

end
