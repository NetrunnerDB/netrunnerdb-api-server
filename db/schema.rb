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

  create_table "card_set_types", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_card_set_types_on_code", unique: true
  end

  create_table "card_sets", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.text "name", null: false
    t.date "date_release"
    t.integer "size"
    t.text "cycle_code"
    t.text "card_set_type_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_set_type_code"], name: "index_card_sets_on_card_set_type_code"
    t.index ["code"], name: "index_card_sets_on_code", unique: true
    t.index ["cycle_code"], name: "index_card_sets_on_cycle_code"
  end

  create_table "card_types", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_non_id_card_type_pk", unique: true
  end

  create_table "cards", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.text "name", null: false
    t.integer "advancement_requirement"
    t.integer "agenda_points"
    t.integer "base_link"
    t.integer "cost"
    t.integer "deck_limit"
    t.text "faction_code"
    t.integer "influence_cost"
    t.integer "influence_limit"
    t.integer "memory_cost"
    t.integer "minimum_deck_size"
    t.text "side_code"
    t.integer "strength"
    t.text "subtypes"
    t.text "text"
    t.integer "trash_cost"
    t.text "card_type_code", null: false
    t.boolean "uniqueness"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_type_code"], name: "index_cards_on_card_type_code"
    t.index ["code"], name: "index_cards_on_code", unique: true
    t.index ["faction_code"], name: "index_cards_on_faction_code"
    t.index ["side_code"], name: "index_cards_on_side_code"
  end

  create_table "cards_subtypes", id: false, force: :cascade do |t|
    t.text "card_code", null: false
    t.text "subtype_code", null: false
    t.index ["card_code", "subtype_code"], name: "index_cards_subtypes_on_card_code_and_subtype_code"
  end

  create_table "cycles", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_cycles_on_code", unique: true
  end

  create_table "factions", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.boolean "is_mini", null: false
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_factions_on_code", unique: true
  end

  create_table "printings", id: false, force: :cascade do |t|
    t.text "code"
    t.text "card_code"
    t.text "printed_text"
    t.boolean "printed_uniqueness"
    t.text "flavor"
    t.text "illustrator"
    t.integer "position"
    t.integer "quantity"
    t.date "date_release"
    t.text "card_set_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_code"], name: "index_printings_on_card_code"
    t.index ["card_set_code"], name: "index_printings_on_card_set_code"
    t.index ["code"], name: "index_printings_on_code", unique: true
  end

  create_table "sides", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_sides_on_code", unique: true
  end

  create_table "subtypes", id: false, force: :cascade do |t|
    t.text "code", null: false
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_subtypes_on_code", unique: true
  end

  add_foreign_key "cards", "card_types", column: "card_type_code", primary_key: "code"
  add_foreign_key "card_sets", "card_set_types", column: "card_set_type_code", primary_key: "code"
  add_foreign_key "card_sets", "cycles", column: "cycle_code", primary_key: "code"
  add_foreign_key "cards", "factions", column: "faction_code", primary_key: "code"
  add_foreign_key "cards", "sides", column: "side_code", primary_key: "code"
  add_foreign_key "cards_subtypes", "cards", column: "card_code", primary_key: "code"
  add_foreign_key "cards_subtypes", "subtypes", column: "subtype_code", primary_key: "code"
  add_foreign_key "printings", "cards", column: "card_code", primary_key: "code"
  add_foreign_key "printings", "card_sets", column: "card_set_code", primary_key: "code"
end
