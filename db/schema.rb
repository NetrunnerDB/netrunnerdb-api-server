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

ActiveRecord::Schema[7.0].define(version: 2022_07_26_032417) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_cycles", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_release"
  end

  create_table "card_pools", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "format_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_pools_card_cycles", id: false, force: :cascade do |t|
    t.text "card_cycle_id", null: false
    t.text "card_pool_id", null: false
    t.index ["card_cycle_id", "card_pool_id"], name: "index_card_pools_card_cycles_on_card_cycle_id_and_card_pool_id"
  end

  create_table "card_pools_card_sets", id: false, force: :cascade do |t|
    t.text "card_set_id", null: false
    t.text "card_pool_id", null: false
    t.index ["card_set_id", "card_pool_id"], name: "index_card_pools_card_sets_on_card_set_id_and_card_pool_id"
  end

  create_table "card_pools_cards", id: false, force: :cascade do |t|
    t.text "card_id", null: false
    t.text "card_pool_id", null: false
    t.index ["card_id", "card_pool_id"], name: "index_card_pools_cards_on_card_id_and_card_pool_id", unique: true
  end

  create_table "card_set_types", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_sets", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.date "date_release"
    t.integer "size"
    t.text "card_cycle_id"
    t.text "card_set_type_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_subtypes", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_types", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "side_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_type_id"], name: "index_cards_on_card_type_id"
    t.index ["faction_id"], name: "index_cards_on_faction_id"
    t.index ["side_id"], name: "index_cards_on_side_id"
    t.index ["title"], name: "index_cards_unique_title", unique: true
  end

  create_table "cards_card_subtypes", id: false, force: :cascade do |t|
    t.text "card_id", null: false
    t.text "card_subtype_id", null: false
    t.index ["card_id", "card_subtype_id"], name: "index_cards_card_subtypes_on_card_id_and_subtype_id"
  end

  create_table "factions", id: :string, force: :cascade do |t|
    t.boolean "is_mini", null: false
    t.text "name", null: false
    t.text "side_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
  end

  create_table "formats", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "active_snapshot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "illustrators", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "illustrators_printings", id: false, force: :cascade do |t|
    t.string "illustrator_id", null: false
    t.string "printing_id", null: false
    t.index ["illustrator_id", "printing_id"], name: "index_illustrators_printings_on_illustrator_id_and_printing_id", unique: true
  end

  create_table "printings", id: :string, force: :cascade do |t|
    t.text "card_id"
    t.text "card_set_id"
    t.text "printed_text"
    t.text "stripped_printed_text"
    t.boolean "printed_is_unique"
    t.text "flavor"
    t.text "display_illustrators"
    t.integer "position"
    t.integer "quantity"
    t.date "date_release"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "date_start", null: false
    t.integer "point_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions_card_subtypes_banned", id: false, force: :cascade do |t|
    t.text "restriction_id", null: false
    t.text "card_subtype_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions_cards_banned", id: false, force: :cascade do |t|
    t.text "restriction_id", null: false
    t.text "card_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions_cards_global_penalty", id: false, force: :cascade do |t|
    t.text "restriction_id", null: false
    t.text "card_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions_cards_points", id: false, force: :cascade do |t|
    t.text "restriction_id", null: false
    t.text "card_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions_cards_restricted", id: false, force: :cascade do |t|
    t.text "restriction_id", null: false
    t.text "card_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions_cards_universal_faction_cost", id: false, force: :cascade do |t|
    t.text "restriction_id", null: false
    t.text "card_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sides", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "snapshots", id: :string, force: :cascade do |t|
    t.text "format_id", null: false
    t.text "card_pool_id", null: false
    t.text "date_start", null: false
    t.text "restriction_id"
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "card_pools", "formats"
  add_foreign_key "card_pools_card_cycles", "card_cycles"
  add_foreign_key "card_pools_card_cycles", "card_pools"
  add_foreign_key "card_pools_card_sets", "card_pools"
  add_foreign_key "card_pools_card_sets", "card_sets"
  add_foreign_key "card_pools_cards", "card_pools"
  add_foreign_key "card_pools_cards", "cards"
  add_foreign_key "card_sets", "card_cycles"
  add_foreign_key "card_sets", "card_set_types"
  add_foreign_key "card_types", "sides"
  add_foreign_key "cards", "card_types"
  add_foreign_key "cards", "factions"
  add_foreign_key "cards", "sides"
  add_foreign_key "cards_card_subtypes", "card_subtypes"
  add_foreign_key "cards_card_subtypes", "cards"
  add_foreign_key "factions", "sides"
  add_foreign_key "printings", "card_sets"
  add_foreign_key "printings", "cards"
  add_foreign_key "restrictions_card_subtypes_banned", "card_subtypes"
  add_foreign_key "restrictions_card_subtypes_banned", "restrictions"
  add_foreign_key "restrictions_cards_banned", "cards"
  add_foreign_key "restrictions_cards_banned", "restrictions"
  add_foreign_key "restrictions_cards_global_penalty", "cards"
  add_foreign_key "restrictions_cards_global_penalty", "restrictions"
  add_foreign_key "restrictions_cards_points", "cards"
  add_foreign_key "restrictions_cards_points", "restrictions"
  add_foreign_key "restrictions_cards_restricted", "cards"
  add_foreign_key "restrictions_cards_restricted", "restrictions"
  add_foreign_key "restrictions_cards_universal_faction_cost", "cards"
  add_foreign_key "restrictions_cards_universal_faction_cost", "restrictions"
  add_foreign_key "snapshots", "card_pools"
  add_foreign_key "snapshots", "formats"
  add_foreign_key "snapshots", "restrictions"

  create_view "test_view", sql_definition: <<-SQL
      WITH cards_cross_restrictions_and_snapshots AS (
           SELECT cards.faction_id,
              cards.id AS card_id,
              restrictions.id AS restriction_id,
              snapshots.id AS snapshot_id,
              snapshots.format_id,
              snapshots.card_pool_id,
              snapshots.date_start AS snapshot_date_start
             FROM cards,
              (restrictions
               JOIN snapshots ON (((restrictions.id)::text = snapshots.restriction_id)))
          )
   SELECT cards_cross_restrictions_and_snapshots.format_id,
      cards_cross_restrictions_and_snapshots.card_pool_id,
      cards_cross_restrictions_and_snapshots.snapshot_id,
      cards_cross_restrictions_and_snapshots.faction_id,
      cards_cross_restrictions_and_snapshots.card_id,
      cards_cross_restrictions_and_snapshots.restriction_id,
      cards_cross_restrictions_and_snapshots.snapshot_date_start,
          CASE
              WHEN (restrictions_cards_banned.restriction_id IS NOT NULL) THEN true
              ELSE false
          END AS is_banned,
          CASE
              WHEN (restrictions_cards_restricted.restriction_id IS NOT NULL) THEN true
              ELSE false
          END AS is_restricted,
      COALESCE(restrictions_cards_points.value, 0) AS eternal_points,
      COALESCE(restrictions_cards_global_penalty.value, 0) AS global_penalty,
      COALESCE(restrictions_cards_universal_faction_cost.value, 0) AS universal_faction_cost
     FROM (((((cards_cross_restrictions_and_snapshots
       LEFT JOIN restrictions_cards_banned ON (((restrictions_cards_banned.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_banned.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_points ON (((restrictions_cards_points.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_points.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_global_penalty ON (((restrictions_cards_global_penalty.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_global_penalty.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_restricted ON (((restrictions_cards_restricted.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_restricted.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_universal_faction_cost ON (((restrictions_cards_universal_faction_cost.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_universal_faction_cost.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
    ORDER BY cards_cross_restrictions_and_snapshots.faction_id, cards_cross_restrictions_and_snapshots.card_id, cards_cross_restrictions_and_snapshots.format_id, cards_cross_restrictions_and_snapshots.snapshot_date_start;
  SQL
  create_view "unified_restrictions", materialized: true, sql_definition: <<-SQL
      WITH cards_cross_restrictions_and_snapshots AS (
           SELECT cards.id AS card_id,
              restrictions.id AS restriction_id,
              snapshots.id AS snapshot_id,
              snapshots.format_id,
              snapshots.card_pool_id,
              snapshots.date_start AS snapshot_date_start
             FROM cards,
              (restrictions
               JOIN snapshots ON (((restrictions.id)::text = snapshots.restriction_id)))
          )
   SELECT cards_cross_restrictions_and_snapshots.format_id,
      cards_cross_restrictions_and_snapshots.card_pool_id,
      cards_cross_restrictions_and_snapshots.snapshot_id,
      cards_cross_restrictions_and_snapshots.snapshot_date_start,
      cards_cross_restrictions_and_snapshots.restriction_id,
      cards_cross_restrictions_and_snapshots.card_id,
          CASE
              WHEN (restrictions_cards_banned.restriction_id IS NOT NULL) THEN true
              ELSE false
          END AS is_banned,
          CASE
              WHEN (restrictions_cards_restricted.restriction_id IS NOT NULL) THEN true
              ELSE false
          END AS is_restricted,
      COALESCE(restrictions_cards_points.value, 0) AS eternal_points,
      COALESCE(restrictions_cards_global_penalty.value, 0) AS global_penalty,
      COALESCE(restrictions_cards_universal_faction_cost.value, 0) AS universal_faction_cost
     FROM ((((((cards_cross_restrictions_and_snapshots
       JOIN card_pools_cards ON (((card_pools_cards.card_pool_id = cards_cross_restrictions_and_snapshots.card_pool_id) AND (card_pools_cards.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_banned ON (((restrictions_cards_banned.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_banned.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_points ON (((restrictions_cards_points.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_points.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_global_penalty ON (((restrictions_cards_global_penalty.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_global_penalty.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_restricted ON (((restrictions_cards_restricted.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_restricted.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))))
       LEFT JOIN restrictions_cards_universal_faction_cost ON (((restrictions_cards_universal_faction_cost.restriction_id = (cards_cross_restrictions_and_snapshots.restriction_id)::text) AND (restrictions_cards_universal_faction_cost.card_id = (cards_cross_restrictions_and_snapshots.card_id)::text))));
  SQL
  add_index "unified_restrictions", ["card_id"], name: "index_unified_restrictions_on_card_id"
  add_index "unified_restrictions", ["card_pool_id"], name: "index_unified_restrictions_on_card_pool_id"
  add_index "unified_restrictions", ["format_id"], name: "index_unified_restrictions_on_format_id"
  add_index "unified_restrictions", ["restriction_id"], name: "index_unified_restrictions_on_restriction_id"
  add_index "unified_restrictions", ["snapshot_id"], name: "index_unified_restrictions_on_snapshot_id"

end
