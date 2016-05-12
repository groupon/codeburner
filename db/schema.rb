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

ActiveRecord::Schema.define(version: 20160512151442) do

  create_table "branches", force: :cascade do |t|
    t.integer  "service_id", limit: 4
    t.string   "ref",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "branches", ["service_id"], name: "index_branches_on_service_id", using: :btree

  create_table "burns", force: :cascade do |t|
    t.string   "revision",       limit: 255
    t.string   "status",         limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "repo_url",       limit: 255
    t.string   "code_lang",      limit: 255
    t.integer  "num_files",      limit: 4
    t.integer  "num_lines",      limit: 4
    t.integer  "service_id",     limit: 4
    t.boolean  "service_portal"
    t.text     "status_reason",  limit: 65535
    t.integer  "user_id",        limit: 4
    t.boolean  "report_status"
    t.string   "pull_request",   limit: 255
    t.integer  "branch_id",      limit: 4
  end

  add_index "burns", ["service_id"], name: "index_burns_on_service_id", using: :btree
  add_index "burns", ["user_id"], name: "index_burns_on_user_id", using: :btree

  create_table "burns_findings", id: false, force: :cascade do |t|
    t.integer "burn_id",    limit: 4, null: false
    t.integer "finding_id", limit: 4, null: false
  end

  create_table "filters", force: :cascade do |t|
    t.integer  "service_id",  limit: 4
    t.integer  "severity",    limit: 4
    t.string   "fingerprint", limit: 255
    t.string   "scanner",     limit: 255
    t.string   "description", limit: 255
    t.string   "detail",      limit: 255
    t.string   "file",        limit: 255
    t.string   "line",        limit: 255
    t.text     "code",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "filters", ["service_id"], name: "index_filters_on_service_id", using: :btree

  create_table "findings", force: :cascade do |t|
    t.string   "description",    limit: 255
    t.integer  "severity",       limit: 4
    t.string   "fingerprint",    limit: 255
    t.text     "detail",         limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "status",         limit: 4
    t.integer  "service_id",     limit: 4
    t.string   "scanner",        limit: 255
    t.text     "file",           limit: 65535
    t.integer  "line",           limit: 4
    t.text     "code",           limit: 65535
    t.integer  "filter_id",      limit: 4
    t.string   "first_appeared", limit: 255
    t.boolean  "current"
  end

  add_index "findings", ["filter_id"], name: "index_findings_on_filter_id", using: :btree
  add_index "findings", ["service_id"], name: "index_findings_on_service_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "burn",        limit: 255
    t.string   "method",      limit: 255
    t.string   "destination", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "service_stats", force: :cascade do |t|
    t.integer  "service_id",         limit: 4
    t.integer  "burns",              limit: 4
    t.integer  "total_findings",     limit: 4
    t.integer  "open_findings",      limit: 4
    t.integer  "filtered_findings",  limit: 4
    t.integer  "hidden_findings",    limit: 4
    t.integer  "published_findings", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "service_stats", ["service_id"], name: "index_service_stats_on_service_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "short_name",      limit: 255
    t.string   "pretty_name",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "service_portal"
    t.string   "html_url",        limit: 255
    t.string   "languages",       limit: 255
    t.integer  "webhook_user_id", limit: 4
  end

  add_index "services", ["webhook_user_id"], name: "index_services_on_webhook_user_id", using: :btree

  create_table "services_users", id: false, force: :cascade do |t|
    t.integer "service_id", limit: 4
    t.integer "user_id",    limit: 4
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255,   null: false
    t.text     "value",      limit: 65535
    t.integer  "thing_id",   limit: 4
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "system_stats", force: :cascade do |t|
    t.integer  "services",           limit: 4
    t.integer  "burns",              limit: 4
    t.integer  "total_findings",     limit: 4
    t.integer  "open_findings",      limit: 4
    t.integer  "hidden_findings",    limit: 4
    t.integer  "published_findings", limit: 4
    t.integer  "filtered_findings",  limit: 4
    t.integer  "files",              limit: 4
    t.integer  "lines",              limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.string   "token",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "tokens", ["user_id"], name: "index_tokens_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "github_uid",   limit: 4
    t.string   "name",         limit: 255
    t.string   "profile_url",  limit: 255
    t.string   "avatar_url",   limit: 255
    t.string   "access_token", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "role",         limit: 4
    t.string   "fullname",     limit: 255
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,        null: false
    t.integer  "item_id",    limit: 4,          null: false
    t.string   "event",      limit: 255,        null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 4294967295
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "branches", "services"
  add_foreign_key "burns", "services"
  add_foreign_key "burns", "users"
  add_foreign_key "filters", "services"
  add_foreign_key "findings", "filters"
  add_foreign_key "findings", "services"
  add_foreign_key "service_stats", "services"
  add_foreign_key "services", "users", column: "webhook_user_id"
  add_foreign_key "tokens", "users"
end
