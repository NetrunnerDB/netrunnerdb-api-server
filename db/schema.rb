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

ActiveRecord::Schema.define(version: 2022_02_13_014409) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_set_types", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "card_sets", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.date "date_release"
    t.integer "size"
    t.text "card_cycle_id"
    t.text "card_set_type_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "card_types", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cards", id: :string, force: :cascade do |t|
    t.text "title", null: false
    t.text "stripped_title", null: false
    t.text "card_type_id", null: false
    t.text "side_id", null: false
    t.text "faction_id", null: false
    t.integer "advancement_requirement"
    t.integer "agenda_points"
    t.integer "base_link"
    t.integer "cost"
    t.integer "deck_limit"
    t.integer "influence_cost"
    t.integer "influence_limit"
    t.integer "memory_cost"
    t.integer "minimum_deck_size"
    t.integer "strength"
    t.text "stripped_text"
    t.text "text"
    t.integer "trash_cost"
    t.boolean "is_unique"
    t.text "display_subtypes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_type_id"], name: "index_cards_on_card_type_id"
    t.index ["faction_id"], name: "index_cards_on_faction_id"
    t.index ["side_id"], name: "index_cards_on_side_id"
    t.index ["title"], name: "index_cards_unique_title", unique: true
  end

  create_table "cards_subtypes", id: false, force: :cascade do |t|
    t.text "card_id", null: false
    t.text "subtype_id", null: false
    t.index ["card_id", "subtype_id"], name: "index_cards_subtypes_on_card_id_and_subtype_id"
  end

  create_table "card_cycles", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "factions", id: :string, force: :cascade do |t|
    t.boolean "is_mini", null: false
    t.text "name", null: false
    t.text "side_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "printings", id: :string, force: :cascade do |t|
    t.text "card_id"
    t.text "card_set_id"
    t.text "printed_text"
    t.text "stripped_printed_text"
    t.boolean "printed_is_unique"
    t.text "flavor"
    t.text "illustrator"
    t.integer "position"
    t.integer "quantity"
    t.date "date_release"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sides", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subtypes", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "formats", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "active_snapshot_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "snapshots", id: :string, force: :cascade do |t|
    t.text "format_id", null: false
    t.text "card_pool_id", null: false
    t.text "date_start", null: false
    t.text "mwl_id"
    t.boolean "active", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "card_pools", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "card_pools_cycles", id: false, force: :cascade do |t|
    t.text "card_cycle_id", null: false
    t.text "card_pool_id", null: false
    t.index ["card_cycle_id", "card_pool_id"], name: "index_card_pools_cycles_on_card_cycle_id_and_card_pool_id"
  end

  create_table "card_pools_sets", id: false, force: :cascade do |t|
    t.text "card_set_id", null: false
    t.text "card_pool_id", null: false
    t.index ["card_set_id", "card_pool_id"], name: "index_card_pools_sets_on_card_set_id_and_card_pool_id"
  end

  create_table "card_pools_cards", id: false, force: :cascade do |t|
    t.text "card_id", null: false
    t.text "card_pool_id", null: false
    t.index ["card_id", "card_pool_id"], name: "index_card_pools_cards_on_card_id_and_card_pool_id"
  end

  create_table "mwls", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "date_start", null: false
    t.integer "point_limit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mwls_cards", id: :string, force: :cascade do |t|
    t.text "mwl_id", null: false
    t.text "card_id", null: false
    t.integer "global_penalty"
    t.integer "universal_faction_cost"
    t.boolean "is_restricted"
    t.boolean "is_banned"
    t.integer "points"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mwls_subtypes", id: :string, force: :cascade do |t|
    t.text "mwl_id", null: false
    t.text "subtype_id", null: false
    t.integer "global_penalty"
    t.integer "universal_faction_cost"
    t.boolean "is_restricted"
    t.boolean "is_banned"
    t.integer "points"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "card_sets", "card_cycles", column: "card_cycle_id", primary_key: "id"
  add_foreign_key "card_sets", "card_set_types", column: "card_set_type_id", primary_key: "id"
  add_foreign_key "cards_subtypes", "cards", column: "card_id", primary_key: "id"
  add_foreign_key "cards_subtypes", "subtypes", column: "subtype_id", primary_key: "id"
  add_foreign_key "cards", "card_types", column: "card_type_id", primary_key: "id"
  add_foreign_key "cards", "factions", column: "faction_id", primary_key: "id"
  add_foreign_key "cards", "sides", column: "side_id", primary_key: "id"
  add_foreign_key "factions", "sides", column: "side_id", primary_key: "id"
  add_foreign_key "printings", "cards", column: "card_id", primary_key: "id"
  add_foreign_key "printings", "card_sets", column: "card_set_id", primary_key: "id"
  add_foreign_key "snapshots", "formats", column: "format_id", primary_key: "id"
  add_foreign_key "snapshots", "card_pools", column: "card_pool_id", primary_key: "id"
  add_foreign_key "snapshots", "mwls", column: "mwl_id", primary_key: "id"
  add_foreign_key "card_pools_cycles", "card_cycles", column: "card_cycle_id", primary_key: "id"
  add_foreign_key "card_pools_cycles", "card_pools", column: "card_pool_id", primary_key: "id"
  add_foreign_key "card_pools_sets", "card_sets", column: "card_set_id", primary_key: "id"
  add_foreign_key "card_pools_sets", "card_pools", column: "card_pool_id", primary_key: "id"
  add_foreign_key "card_pools_cards", "cards", column: "card_id", primary_key: "id"
  add_foreign_key "card_pools_cards", "card_pools", column: "card_pool_id", primary_key: "id"
  add_foreign_key "mwls_cards", "cards", column: "card_id", primary_key: "id"
  add_foreign_key "mwls_cards", "mwls", column: "mwl_id", primary_key: "id"
  add_foreign_key "mwls_subtypes", "mwls", column: "mwl_id", primary_key: "id"
  add_foreign_key "mwls_subtypes", "subtypes", column: "subtype_id", primary_key: "id"
end
