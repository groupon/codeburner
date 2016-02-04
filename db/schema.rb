#
#The MIT License (MIT)
#
#Copyright (c) 2016, Groupon, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
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

ActiveRecord::Schema.define(version: 20151210032652) do

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
  end

  add_index "burns", ["service_id"], name: "index_burns_on_service_id", using: :btree

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
    t.string   "description", limit: 255
    t.integer  "severity",    limit: 4
    t.string   "fingerprint", limit: 255
    t.text     "detail",      limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "status",      limit: 4
    t.integer  "burn_id",     limit: 4
    t.integer  "service_id",  limit: 4
    t.string   "scanner",     limit: 255
    t.string   "file",        limit: 255
    t.integer  "line",        limit: 4
    t.text     "code",        limit: 65535
    t.integer  "filter_id",   limit: 4
  end

  add_index "findings", ["burn_id"], name: "index_findings_on_burn_id", using: :btree
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
    t.string   "short_name",     limit: 255
    t.string   "pretty_name",    limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "service_portal"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

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

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,        null: false
    t.integer  "item_id",    limit: 4,          null: false
    t.string   "event",      limit: 255,        null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 4294967295
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "burns", "services"
  add_foreign_key "filters", "services"
  add_foreign_key "findings", "burns"
  add_foreign_key "findings", "filters"
  add_foreign_key "findings", "services"
  add_foreign_key "service_stats", "services"
end
