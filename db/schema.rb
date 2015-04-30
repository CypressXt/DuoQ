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

ActiveRecord::Schema.define(version: 20150428115205) do

  create_table "app_users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",      limit: 255
    t.string   "email",         limit: 255
    t.string   "password",      limit: 255
    t.boolean  "mailConfirmed"
  end

  create_table "league_divisions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "league_tiers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "match_participants", force: :cascade do |t|
    t.integer  "participant_number"
    t.integer  "match_team_id"
    t.integer  "summoner_id"
    t.integer  "league_tier_id"
    t.integer  "league_division_id"
    t.integer  "summoner_level"
    t.integer  "spell1_id"
    t.integer  "spell2_id"
    t.integer  "champion_id"
    t.integer  "champion_level"
    t.integer  "item0_id"
    t.integer  "item1_id"
    t.integer  "item2_id"
    t.integer  "item3_id"
    t.integer  "item4_id"
    t.integer  "item5_id"
    t.integer  "item6_id"
    t.integer  "kills"
    t.integer  "double_kills"
    t.integer  "triple_kills"
    t.integer  "quadra_kills"
    t.integer  "penta_kills"
    t.integer  "unreal_kills"
    t.integer  "largest_killing_spree"
    t.integer  "deaths"
    t.integer  "assists"
    t.integer  "total_damage_dealt"
    t.integer  "total_damage_dealt_to_champions"
    t.integer  "total_damage_taken"
    t.integer  "largest_critical_strike"
    t.integer  "total_heal"
    t.integer  "minions_killed"
    t.integer  "neutral_minions_killed"
    t.integer  "neutral_minions_killed_team_jungle"
    t.integer  "neutral_minions_killed_enemy_jungle"
    t.integer  "gold_earned"
    t.integer  "gold_spent"
    t.integer  "combat_player_score"
    t.integer  "objective_player_score"
    t.integer  "total_player_score"
    t.integer  "total_score_rank"
    t.integer  "magic_damage_dealt_to_champions"
    t.integer  "physical_damage_dealt_to_champions"
    t.integer  "true_damage_dealt_to_champions"
    t.integer  "vision_wards_bought_in_game"
    t.integer  "sight_wards_bought_in_game"
    t.integer  "magic_damage_dealt"
    t.integer  "physical_damage_dealt"
    t.integer  "true_damage_dealt"
    t.integer  "magic_damage_taken"
    t.integer  "physical_damage_taken"
    t.integer  "true_damage_taken"
    t.boolean  "first_blood_kill"
    t.boolean  "first_blood_assist"
    t.boolean  "first_tower_kill"
    t.boolean  "first_tower_assist"
    t.boolean  "first_inhibitor_kill"
    t.boolean  "first_inhibitor_assist"
    t.integer  "inhibitor_kills"
    t.integer  "tower_kills"
    t.integer  "wards_placed"
    t.integer  "wards_killed"
    t.integer  "largest_multi_kill"
    t.integer  "killing_sprees"
    t.integer  "total_units_healed"
    t.integer  "total_time_crowd_control_dealt"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "match_participants", ["champion_id"], name: "index_match_participants_on_champion_id"
  add_index "match_participants", ["item0_id"], name: "index_match_participants_on_item0_id"
  add_index "match_participants", ["item1_id"], name: "index_match_participants_on_item1_id"
  add_index "match_participants", ["item2_id"], name: "index_match_participants_on_item2_id"
  add_index "match_participants", ["item3_id"], name: "index_match_participants_on_item3_id"
  add_index "match_participants", ["item4_id"], name: "index_match_participants_on_item4_id"
  add_index "match_participants", ["item5_id"], name: "index_match_participants_on_item5_id"
  add_index "match_participants", ["item6_id"], name: "index_match_participants_on_item6_id"
  add_index "match_participants", ["league_division_id"], name: "index_match_participants_on_league_division_id"
  add_index "match_participants", ["league_tier_id"], name: "index_match_participants_on_league_tier_id"
  add_index "match_participants", ["match_team_id"], name: "index_match_participants_on_match_team_id"
  add_index "match_participants", ["spell1_id"], name: "index_match_participants_on_spell1_id"
  add_index "match_participants", ["spell2_id"], name: "index_match_participants_on_spell2_id"
  add_index "match_participants", ["summoner_id"], name: "index_match_participants_on_summoner_id"

  create_table "match_teams", force: :cascade do |t|
    t.integer  "riot_id"
    t.boolean  "won"
    t.boolean  "first_blood"
    t.boolean  "first_tower"
    t.boolean  "first_inhibitor"
    t.boolean  "first_baron"
    t.boolean  "first_dragon"
    t.integer  "tower_kills"
    t.integer  "inhibitor_kills"
    t.integer  "baron_kills"
    t.integer  "dragon_kills"
    t.integer  "vilemaw_kills"
    t.integer  "match_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "match_teams", ["match_id"], name: "index_match_teams_on_match_id"

  create_table "matches", force: :cascade do |t|
    t.decimal  "riot_id"
    t.datetime "match_date"
    t.integer  "duration"
    t.integer  "team_type_id"
    t.string   "version"
    t.integer  "season_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "matches", ["season_id"], name: "index_matches_on_season_id"
  add_index "matches", ["team_type_id"], name: "index_matches_on_team_type_id"

  create_table "regions", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "endpoint",      limit: 255
    t.string   "chat_endpoint", limit: 255
  end

  create_table "relation_team_app_users", force: :cascade do |t|
    t.integer "team_id"
    t.integer "app_user_id"
  end

  add_index "relation_team_app_users", ["app_user_id"], name: "index_relation_team_app_users_on_app_user_id"
  add_index "relation_team_app_users", ["team_id"], name: "index_relation_team_app_users_on_team_id"

  create_table "relation_team_matches", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "relation_team_matches", ["match_id"], name: "index_relation_team_matches_on_match_id"
  add_index "relation_team_matches", ["team_id"], name: "index_relation_team_matches_on_team_id"

  create_table "seasons", force: :cascade do |t|
    t.string   "name"
    t.string   "riot_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "summoners", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_user_id"
    t.integer  "summonerLevel"
    t.string   "summonerToken",      limit: 255
    t.boolean  "validated"
    t.integer  "region_id"
    t.integer  "league_tier_id"
    t.integer  "league_division_id"
  end

  add_index "summoners", ["app_user_id"], name: "index_summoners_on_app_user_id"
  add_index "summoners", ["league_division_id"], name: "index_summoners_on_league_division_id"
  add_index "summoners", ["league_tier_id"], name: "index_summoners_on_league_tier_id"
  add_index "summoners", ["region_id"], name: "index_summoners_on_region_id"

  create_table "team_compositions", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "summoner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "player_status_id"
  end

  add_index "team_compositions", ["player_status_id"], name: "index_team_compositions_on_player_status_id"
  add_index "team_compositions", ["summoner_id"], name: "index_team_compositions_on_summoner_id"
  add_index "team_compositions", ["team_id"], name: "index_team_compositions_on_team_id"

  create_table "team_player_statuses", force: :cascade do |t|
    t.string "label", limit: 255
  end

  create_table "team_types", force: :cascade do |t|
    t.integer  "number_players"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           limit: 255
    t.string   "key",            limit: 255
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "team_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag",                limit: 255
    t.integer  "league_tier_id"
    t.integer  "league_division_id"
    t.string   "key",                limit: 255
  end

  add_index "teams", ["id"], name: "index_teams_on_id"
  add_index "teams", ["league_division_id"], name: "index_teams_on_league_division_id"
  add_index "teams", ["league_tier_id"], name: "index_teams_on_league_tier_id"
  add_index "teams", ["team_type_id"], name: "index_teams_on_team_type_id"

end
