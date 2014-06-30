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

ActiveRecord::Schema.define(version: 20140630203645) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.integer "user_id"
    t.integer "commentable_id"
    t.string  "commentable_type"
    t.text    "content"
  end

  create_table "links", force: true do |t|
    t.integer  "user_id"
    t.text     "url",        null: false
    t.text     "title",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["user_id"], name: "index_links_on_user_id", using: :btree

  create_table "statuses", force: true do |t|
    t.integer  "user_id"
    t.text     "content",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["user_id"], name: "index_statuses_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
