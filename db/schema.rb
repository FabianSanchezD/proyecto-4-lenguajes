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

ActiveRecord::Schema[7.1].define(version: 2026_01_01_000004) do
  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.integer "stage", default: 0, null: false
    t.integer "group_id"
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "home_goals"
    t.integer "away_goals"
    t.integer "home_penalties"
    t.integer "away_penalties"
    t.boolean "played", default: false, null: false
    t.integer "slot"
    t.integer "next_match_id"
    t.string "next_slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["group_id"], name: "index_matches_on_group_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["next_match_id"], name: "index_matches_on_next_match_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.integer "group_id"
    t.integer "points", default: 0, null: false
    t.integer "goals_for", default: 0, null: false
    t.integer "goals_against", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pot"
    t.index ["group_id"], name: "index_teams_on_group_id"
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  add_foreign_key "matches", "groups"
  add_foreign_key "matches", "matches", column: "next_match_id"
  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
  add_foreign_key "teams", "groups"
end
