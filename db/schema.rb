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

ActiveRecord::Schema.define(version: 20150205131524) do

  create_table "app_users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.boolean  "mailConfirmed"
  end

  create_table "regions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relation_team_app_users", force: true do |t|
    t.integer "team_id"
    t.integer "app_user_id"
  end

  add_index "relation_team_app_users", ["app_user_id"], name: "index_relation_team_app_users_on_app_user_id"
  add_index "relation_team_app_users", ["team_id"], name: "index_relation_team_app_users_on_team_id"

  create_table "summoners", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_user_id"
    t.integer  "summonerLevel"
    t.string   "summonerToken"
    t.boolean  "validated"
  end

  add_index "summoners", ["app_user_id"], name: "index_summoners_on_app_user_id"

  create_table "team_compositions", force: true do |t|
    t.integer  "team_id"
    t.integer  "summoner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_compositions", ["summoner_id"], name: "index_team_compositions_on_summoner_id"
  add_index "team_compositions", ["team_id"], name: "index_team_compositions_on_team_id"

  create_table "team_types", force: true do |t|
    t.integer  "number_players"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "key"
  end

  create_table "teams", force: true do |t|
    t.string  "name"
    t.string  "riot_key"
    t.integer "nb_player"
    t.integer "team_types_id"
  end

  add_index "teams", ["team_types_id"], name: "index_teams_on_team_types_id"

end
