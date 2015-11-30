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

ActiveRecord::Schema.define(version: 20151120183638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "captures", force: :cascade do |t|
    t.integer  "upload_id",          null: false
    t.integer  "user_id",            null: false
    t.string   "original_file_name", null: false
    t.string   "file_name",          null: false
    t.string   "file_type",          null: false
    t.string   "file_path",          null: false
    t.integer  "file_size",          null: false
    t.string   "file_digest",        null: false
    t.string   "client_build"
    t.string   "client_locale"
    t.string   "format_version"
    t.datetime "capture_time"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "uploads", force: :cascade do |t|
    t.integer  "user_id",                            null: false
    t.string   "original_file_name",                 null: false
    t.string   "file_name",                          null: false
    t.string   "file_type",                          null: false
    t.string   "file_path",                          null: false
    t.integer  "file_size",                          null: false
    t.string   "file_digest",                        null: false
    t.boolean  "archive",            default: false, null: false
    t.boolean  "unsupported",        default: false, null: false
    t.boolean  "deleted",            default: false, null: false
    t.boolean  "processed",          default: false, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",           null: false
    t.string   "name",            null: false
    t.string   "hashed_password"
    t.string   "external_auth"
    t.string   "uploader_token"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
