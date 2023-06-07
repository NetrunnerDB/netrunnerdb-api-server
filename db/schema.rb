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

ActiveRecord::Schema[7.0].define(version: 2023_05_23_073031) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "card_cycles", id: :string, force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_release"
    t.string "legacy_code"
  end

  create_table "card_faces", id: :string, force: :cascade do |t|
    t.string "card_id", null: false
    t.text "title"
    t.text "stripped_title"
    t.text "base_link"
    t.integer "advancement_requirement"
    t.integer "agenda_points"
    t.integer "cost"
    t.integer "memory_cost"
    t.integer "strength"
    t.text "text"
    t.text "stripped_text"
    t.integer "trash_cost"
    t.boolean "is_unique"
    t.text "display_subtypes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_faces_card_subtypes", id: false, force: :cascade do |t|
    t.string "card_face_id", null: false
    t.string "card_subtype_id", null: false
    t.index ["card_face_id", "card_subtype_id"], name: "index_card_faces_card_subtypes_on_face_id_and_subtype_id", unique: true
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
    t.string "legacy_code"
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
    t.boolean "additional_cost", default: false
    t.boolean "advanceable", default: false
    t.boolean "gains_subroutines", default: false
    t.boolean "interrupt", default: false
    t.integer "link_provided"
    t.integer "mu_provided"
    t.integer "num_printed_subroutines"
    t.boolean "on_encounter_effect", default: false
    t.boolean "performs_trace", default: false
    t.integer "recurring_credits_provided"
    t.boolean "rez_effect", default: false
    t.boolean "trash_ability", default: false
    t.string "attribution"
    t.string "layout_id"
    t.index ["card_type_id"], name: "index_cards_on_card_type_id"
    t.index ["faction_id"], name: "index_cards_on_faction_id"
    t.index ["side_id"], name: "index_cards_on_side_id"
    t.index ["title"], name: "index_cards_unique_title", unique: true
  end

  create_table "cards_card_faces", id: false, force: :cascade do |t|
    t.string "card_id", null: false
    t.string "card_face_id", null: false
    t.index ["card_id", "card_face_id"], name: "index_cards_card_faces_on_card_id_and_card_face_id", unique: true
  end

  create_table "cards_card_subtypes", id: false, force: :cascade do |t|
    t.text "card_id", null: false
    t.text "card_subtype_id", null: false
    t.index ["card_id", "card_subtype_id"], name: "index_cards_card_subtypes_on_card_id_and_subtype_id"
  end

  create_table "decks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "user_id", null: false
    t.boolean "follows_basic_deckbuilding_rules", default: true, null: false
    t.string "identity_card_id", null: false
    t.string "side_id", null: false
    t.string "name", null: false
    t.string "notes", default: "", null: false
    t.string "tags", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tags"], name: "index_decks_on_tags", using: :gin
  end

  create_table "decks_cards", id: false, force: :cascade do |t|
    t.uuid "deck_id", null: false
    t.string "card_id", null: false
    t.integer "quantity", null: false
    t.index ["deck_id", "card_id"], name: "index_decks_cards_on_deck_id_and_card_id", unique: true
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
    t.integer "num_printings"
  end

  create_table "illustrators_printings", id: false, force: :cascade do |t|
    t.string "illustrator_id", null: false
    t.string "printing_id", null: false
    t.index ["illustrator_id", "printing_id"], name: "index_illustrators_printings_on_illustrator_id_and_printing_id", unique: true
  end

  create_table "printing_faces", id: :string, force: :cascade do |t|
    t.string "printing_id", null: false
    t.text "flavor"
    t.text "display_illustrators"
    t.integer "copy_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "printing_faces_illustrators", id: false, force: :cascade do |t|
    t.string "printing_face_id", null: false
    t.string "illustrator_id", null: false
    t.index ["printing_face_id", "illustrator_id"], name: "index_printing_faces_illustrators_on_face_id_and_illustrator_id", unique: true
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
    t.string "layout_id"
  end

  create_table "printings_printing_faces", id: false, force: :cascade do |t|
    t.string "printing_id", null: false
    t.string "printing_face_id", null: false
    t.index ["printing_id", "printing_face_id"], name: "index_printings_printing_faces_on_printing_id_and_face_id", unique: true
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

  create_table "ruling_sources", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rulings", force: :cascade do |t|
    t.string "card_id", null: false
    t.string "question"
    t.string "answer"
    t.string "text_ruling"
    t.boolean "nsg_rules_team_verified", null: false
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

  create_table "users", id: :string, force: :cascade do |t|
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
  add_foreign_key "decks", "cards", column: "identity_card_id"
  add_foreign_key "decks", "sides"
  add_foreign_key "decks", "users"
  add_foreign_key "decks_cards", "cards"
  add_foreign_key "decks_cards", "decks"
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
  add_foreign_key "rulings", "cards"
  add_foreign_key "snapshots", "card_pools"
  add_foreign_key "snapshots", "formats"
  add_foreign_key "snapshots", "restrictions"

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
      ((restrictions_cards_banned.restriction_id IS NOT NULL) OR (restrictions_cards_restricted.restriction_id IS NOT NULL) OR (restrictions_cards_points.restriction_id IS NOT NULL) OR (restrictions_cards_global_penalty.restriction_id IS NOT NULL) OR (restrictions_cards_universal_faction_cost.restriction_id IS NOT NULL)) AS in_restriction,
          CASE
              WHEN (restrictions_cards_banned.restriction_id IS NOT NULL) THEN true
              ELSE false
          END AS is_banned,
          CASE
              WHEN (restrictions_cards_restricted.restriction_id IS NOT NULL) THEN true
              ELSE false
          END AS is_restricted,
      COALESCE(restrictions_cards_points.value, 0) AS eternal_points,
          CASE
              WHEN (restrictions_cards_global_penalty.restriction_id IS NOT NULL) THEN true
              ELSE false
          END AS has_global_penalty,
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
  add_index "unified_restrictions", ["in_restriction"], name: "index_unified_restrictions_on_in_restriction"
  add_index "unified_restrictions", ["restriction_id"], name: "index_unified_restrictions_on_restriction_id"
  add_index "unified_restrictions", ["snapshot_id"], name: "index_unified_restrictions_on_snapshot_id"

  create_view "unified_cards", materialized: true, sql_definition: <<-SQL
      WITH card_cycles_summary AS (
           SELECT c_1.id,
              array_agg(cc.id ORDER BY cc.id) AS card_cycle_ids,
              array_agg(lower(cc.name) ORDER BY (lower(cc.name))) AS card_cycle_names
             FROM (((cards c_1
               JOIN printings p_1 ON (((c_1.id)::text = p_1.card_id)))
               JOIN card_sets cs ON ((p_1.card_set_id = (cs.id)::text)))
               JOIN card_cycles cc ON (((cc.id)::text = cs.card_cycle_id)))
            GROUP BY c_1.id
          ), card_sets_summary AS (
           SELECT c_1.id,
              array_agg(cs.id ORDER BY cs.id) AS card_set_ids,
              array_agg(lower(cs.name) ORDER BY (lower(cs.name))) AS card_set_names
             FROM ((cards c_1
               JOIN printings p_1 ON (((c_1.id)::text = p_1.card_id)))
               JOIN card_sets cs ON ((p_1.card_set_id = (cs.id)::text)))
            GROUP BY c_1.id
          ), card_subtype_ids AS (
           SELECT cards_card_subtypes.card_id,
              array_agg(cards_card_subtypes.card_subtype_id ORDER BY 1::integer) AS card_subtype_ids
             FROM cards_card_subtypes
            GROUP BY cards_card_subtypes.card_id
          ), card_subtype_names AS (
           SELECT ccs_1.card_id,
              array_agg(lower(cs.name) ORDER BY (lower(cs.name))) AS lower_card_subtype_names,
              array_agg(cs.name ORDER BY cs.name) AS card_subtype_names
             FROM (cards_card_subtypes ccs_1
               JOIN card_subtypes cs ON ((ccs_1.card_subtype_id = (cs.id)::text)))
            GROUP BY ccs_1.card_id
          ), card_printing_ids AS (
           SELECT printings.card_id,
              array_agg(printings.id ORDER BY printings.date_release DESC) AS printing_ids
             FROM printings
            GROUP BY printings.card_id
          ), card_release_dates AS (
           SELECT printings.card_id,
              min(printings.date_release) AS date_release
             FROM printings
            GROUP BY printings.card_id
          ), card_restriction_ids AS (
           SELECT unified_restrictions.card_id,
              array_agg(unified_restrictions.restriction_id ORDER BY unified_restrictions.restriction_id) AS restriction_ids
             FROM unified_restrictions
            WHERE unified_restrictions.in_restriction
            GROUP BY unified_restrictions.card_id
          ), restrictions_banned_summary AS (
           SELECT restrictions_cards_banned.card_id,
              array_agg(restrictions_cards_banned.restriction_id ORDER BY restrictions_cards_banned.restriction_id) AS restrictions_banned
             FROM restrictions_cards_banned
            GROUP BY restrictions_cards_banned.card_id
          ), restrictions_global_penalty_summary AS (
           SELECT restrictions_cards_global_penalty.card_id,
              array_agg(restrictions_cards_global_penalty.restriction_id ORDER BY restrictions_cards_global_penalty.restriction_id) AS restrictions_global_penalty
             FROM restrictions_cards_global_penalty
            GROUP BY restrictions_cards_global_penalty.card_id
          ), restrictions_points_summary AS (
           SELECT restrictions_cards_points.card_id,
              array_agg(concat(restrictions_cards_points.restriction_id, '=', (restrictions_cards_points.value)::text) ORDER BY (concat(restrictions_cards_points.restriction_id, '=', (restrictions_cards_points.value)::text))) AS restrictions_points
             FROM restrictions_cards_points
            GROUP BY restrictions_cards_points.card_id
          ), restrictions_restricted_summary AS (
           SELECT restrictions_cards_restricted.card_id,
              array_agg(restrictions_cards_restricted.restriction_id ORDER BY restrictions_cards_restricted.restriction_id) AS restrictions_restricted
             FROM restrictions_cards_restricted
            GROUP BY restrictions_cards_restricted.card_id
          ), restrictions_universal_faction_cost_summary AS (
           SELECT restrictions_cards_universal_faction_cost.card_id,
              array_agg(concat(restrictions_cards_universal_faction_cost.restriction_id, '=', (restrictions_cards_universal_faction_cost.value)::text) ORDER BY (concat(restrictions_cards_universal_faction_cost.restriction_id, '=', (restrictions_cards_universal_faction_cost.value)::text))) AS restrictions_universal_faction_cost
             FROM restrictions_cards_universal_faction_cost
            GROUP BY restrictions_cards_universal_faction_cost.card_id
          ), format_ids AS (
           SELECT cpc_1.card_id,
              array_agg(DISTINCT s_1.format_id ORDER BY s_1.format_id) AS format_ids
             FROM (card_pools_cards cpc_1
               JOIN snapshots s_1 ON ((cpc_1.card_pool_id = s_1.card_pool_id)))
            GROUP BY cpc_1.card_id
          ), card_pool_ids AS (
           SELECT cpc_1.card_id,
              array_agg(DISTINCT s_1.card_pool_id ORDER BY s_1.card_pool_id) AS card_pool_ids
             FROM (card_pools_cards cpc_1
               JOIN snapshots s_1 ON ((cpc_1.card_pool_id = s_1.card_pool_id)))
            GROUP BY cpc_1.card_id
          ), snapshot_ids AS (
           SELECT cpc_1.card_id,
              array_agg(DISTINCT s_1.id ORDER BY s_1.id) AS snapshot_ids
             FROM (card_pools_cards cpc_1
               JOIN snapshots s_1 ON ((cpc_1.card_pool_id = s_1.card_pool_id)))
            GROUP BY cpc_1.card_id
          )
   SELECT c.id,
      c.title,
      c.stripped_title,
      c.card_type_id,
      c.side_id,
      c.faction_id,
      c.advancement_requirement,
      c.agenda_points,
      c.base_link,
      c.cost,
      c.deck_limit,
      c.influence_cost,
      c.influence_limit,
      c.memory_cost,
      c.minimum_deck_size,
      c.strength,
      c.stripped_text,
      c.text,
      c.trash_cost,
      c.is_unique,
      c.display_subtypes,
      c.attribution,
      c.layout_id,
      c.created_at,
      c.updated_at,
      c.additional_cost,
      c.advanceable,
      c.gains_subroutines,
      c.interrupt,
      c.link_provided,
      c.mu_provided,
      c.num_printed_subroutines,
      c.on_encounter_effect,
      c.performs_trace,
      c.recurring_credits_provided,
      c.rez_effect,
      c.trash_ability,
      COALESCE(csi.card_subtype_ids, ARRAY[]::text[]) AS card_subtype_ids,
      COALESCE(csn.lower_card_subtype_names, ARRAY[]::text[]) AS lower_card_subtype_names,
      COALESCE(csn.card_subtype_names, ARRAY[]::text[]) AS card_subtype_names,
      p.printing_ids,
      array_length(p.printing_ids, 1) AS num_printings,
      ccs.card_cycle_ids,
      ccs.card_cycle_names,
      css.card_set_ids,
      css.card_set_names,
      COALESCE(r.restriction_ids, (ARRAY[]::text[])::character varying[]) AS restriction_ids,
      (r.restriction_ids IS NOT NULL) AS in_restriction,
      COALESCE(r_b.restrictions_banned, ARRAY[]::text[]) AS restrictions_banned,
      COALESCE(r_g_p.restrictions_global_penalty, ARRAY[]::text[]) AS restrictions_global_penalty,
      COALESCE(r_p.restrictions_points, ARRAY[]::text[]) AS restrictions_points,
      COALESCE(r_r.restrictions_restricted, ARRAY[]::text[]) AS restrictions_restricted,
      COALESCE(r_u_f_c.restrictions_universal_faction_cost, ARRAY[]::text[]) AS restrictions_universal_faction_cost,
      COALESCE(f.format_ids, ARRAY[]::text[]) AS format_ids,
      COALESCE(cpc.card_pool_ids, ARRAY[]::text[]) AS card_pool_ids,
      COALESCE(s.snapshot_ids, (ARRAY[]::text[])::character varying[]) AS snapshot_ids,
      crd.date_release
     FROM (((((((((((((((cards c
       JOIN card_printing_ids p ON (((c.id)::text = p.card_id)))
       JOIN card_cycles_summary ccs ON (((c.id)::text = (ccs.id)::text)))
       JOIN card_sets_summary css ON (((c.id)::text = (css.id)::text)))
       LEFT JOIN card_subtype_ids csi ON (((c.id)::text = csi.card_id)))
       LEFT JOIN card_subtype_names csn ON (((c.id)::text = csn.card_id)))
       LEFT JOIN card_restriction_ids r ON (((c.id)::text = (r.card_id)::text)))
       LEFT JOIN restrictions_banned_summary r_b ON (((c.id)::text = r_b.card_id)))
       LEFT JOIN restrictions_global_penalty_summary r_g_p ON (((c.id)::text = r_g_p.card_id)))
       LEFT JOIN restrictions_points_summary r_p ON (((c.id)::text = r_p.card_id)))
       LEFT JOIN restrictions_restricted_summary r_r ON (((c.id)::text = r_r.card_id)))
       LEFT JOIN restrictions_universal_faction_cost_summary r_u_f_c ON (((c.id)::text = r_u_f_c.card_id)))
       LEFT JOIN format_ids f ON (((c.id)::text = f.card_id)))
       LEFT JOIN card_pool_ids cpc ON (((c.id)::text = cpc.card_id)))
       LEFT JOIN snapshot_ids s ON (((c.id)::text = s.card_id)))
       LEFT JOIN card_release_dates crd ON (((c.id)::text = crd.card_id)))
    GROUP BY c.id, c.title, c.stripped_title, c.card_type_id, c.side_id, c.faction_id, c.advancement_requirement, c.agenda_points, c.base_link, c.cost, c.deck_limit, c.influence_cost, c.influence_limit, c.memory_cost, c.minimum_deck_size, c.strength, c.stripped_text, c.text, c.trash_cost, c.is_unique, c.display_subtypes, c.attribution, c.created_at, c.updated_at, c.additional_cost, c.advanceable, c.gains_subroutines, c.interrupt, c.link_provided, c.mu_provided, c.num_printed_subroutines, c.on_encounter_effect, c.performs_trace, c.recurring_credits_provided, c.rez_effect, c.trash_ability, csi.card_subtype_ids, csn.lower_card_subtype_names, csn.card_subtype_names, p.printing_ids, ccs.card_cycle_ids, ccs.card_cycle_names, css.card_set_ids, css.card_set_names, r.restriction_ids, r_b.restrictions_banned, r_g_p.restrictions_global_penalty, r_p.restrictions_points, r_r.restrictions_restricted, r_u_f_c.restrictions_universal_faction_cost, f.format_ids, cpc.card_pool_ids, s.snapshot_ids, crd.date_release;
  SQL
  create_view "unified_printings", materialized: true, sql_definition: <<-SQL
      WITH card_cycles_summary AS (
           SELECT c_1.id,
              array_agg(cc_1.id ORDER BY cc_1.id) AS card_cycle_ids,
              array_agg(lower(cc_1.name) ORDER BY (lower(cc_1.name))) AS card_cycle_names
             FROM (((cards c_1
               JOIN printings p_1 ON (((c_1.id)::text = p_1.card_id)))
               JOIN card_sets cs_1 ON ((p_1.card_set_id = (cs_1.id)::text)))
               JOIN card_cycles cc_1 ON (((cc_1.id)::text = cs_1.card_cycle_id)))
            GROUP BY c_1.id
          ), card_sets_summary AS (
           SELECT c_1.id,
              array_agg(cs_1.id ORDER BY cs_1.id) AS card_set_ids,
              array_agg(lower(cs_1.name) ORDER BY (lower(cs_1.name))) AS card_set_names
             FROM ((cards c_1
               JOIN printings p_1 ON (((c_1.id)::text = p_1.card_id)))
               JOIN card_sets cs_1 ON ((p_1.card_set_id = (cs_1.id)::text)))
            GROUP BY c_1.id
          ), card_subtype_ids AS (
           SELECT cards_card_subtypes.card_id,
              array_agg(cards_card_subtypes.card_subtype_id ORDER BY 1::integer) AS card_subtype_ids
             FROM cards_card_subtypes
            GROUP BY cards_card_subtypes.card_id
          ), card_subtype_names AS (
           SELECT ccs_1.card_id,
              array_agg(lower(cs_1.name) ORDER BY (lower(cs_1.name))) AS lower_card_subtype_names,
              array_agg(cs_1.name ORDER BY cs_1.name) AS card_subtype_names
             FROM (cards_card_subtypes ccs_1
               JOIN card_subtypes cs_1 ON ((ccs_1.card_subtype_id = (cs_1.id)::text)))
            GROUP BY ccs_1.card_id
          ), card_printing_ids AS (
           SELECT printings.card_id,
              array_agg(printings.id ORDER BY printings.date_release DESC) AS printing_ids
             FROM printings
            GROUP BY printings.card_id
          ), illustrators AS (
           SELECT ip.printing_id,
              array_agg(ip.illustrator_id ORDER BY ip.illustrator_id) AS illustrator_ids,
              array_agg(i_1.name ORDER BY i_1.name) AS illustrator_names
             FROM (illustrators_printings ip
               JOIN public.illustrators i_1 ON (((ip.illustrator_id)::text = (i_1.id)::text)))
            GROUP BY ip.printing_id
          ), card_restriction_ids AS (
           SELECT unified_restrictions.card_id,
              array_agg(unified_restrictions.restriction_id ORDER BY unified_restrictions.restriction_id) AS restriction_ids
             FROM unified_restrictions
            WHERE unified_restrictions.in_restriction
            GROUP BY unified_restrictions.card_id
          ), restrictions_banned_summary AS (
           SELECT restrictions_cards_banned.card_id,
              array_agg(restrictions_cards_banned.restriction_id ORDER BY restrictions_cards_banned.restriction_id) AS restrictions_banned
             FROM restrictions_cards_banned
            GROUP BY restrictions_cards_banned.card_id
          ), restrictions_global_penalty_summary AS (
           SELECT restrictions_cards_global_penalty.card_id,
              array_agg(restrictions_cards_global_penalty.restriction_id ORDER BY restrictions_cards_global_penalty.restriction_id) AS restrictions_global_penalty
             FROM restrictions_cards_global_penalty
            GROUP BY restrictions_cards_global_penalty.card_id
          ), restrictions_points_summary AS (
           SELECT restrictions_cards_points.card_id,
              array_agg(concat(restrictions_cards_points.restriction_id, '=', (restrictions_cards_points.value)::text) ORDER BY (concat(restrictions_cards_points.restriction_id, '=', (restrictions_cards_points.value)::text))) AS restrictions_points
             FROM restrictions_cards_points
            GROUP BY restrictions_cards_points.card_id
          ), restrictions_restricted_summary AS (
           SELECT restrictions_cards_restricted.card_id,
              array_agg(restrictions_cards_restricted.restriction_id ORDER BY restrictions_cards_restricted.restriction_id) AS restrictions_restricted
             FROM restrictions_cards_restricted
            GROUP BY restrictions_cards_restricted.card_id
          ), restrictions_universal_faction_cost_summary AS (
           SELECT restrictions_cards_universal_faction_cost.card_id,
              array_agg(concat(restrictions_cards_universal_faction_cost.restriction_id, '=', (restrictions_cards_universal_faction_cost.value)::text) ORDER BY (concat(restrictions_cards_universal_faction_cost.restriction_id, '=', (restrictions_cards_universal_faction_cost.value)::text))) AS restrictions_universal_faction_cost
             FROM restrictions_cards_universal_faction_cost
            GROUP BY restrictions_cards_universal_faction_cost.card_id
          ), format_ids AS (
           SELECT cpc_1.card_id,
              array_agg(DISTINCT s_1.format_id ORDER BY s_1.format_id) AS format_ids
             FROM (card_pools_cards cpc_1
               JOIN snapshots s_1 ON ((cpc_1.card_pool_id = s_1.card_pool_id)))
            GROUP BY cpc_1.card_id
          ), card_pool_ids AS (
           SELECT cpc_1.card_id,
              array_agg(DISTINCT s_1.card_pool_id ORDER BY s_1.card_pool_id) AS card_pool_ids
             FROM (card_pools_cards cpc_1
               JOIN snapshots s_1 ON ((cpc_1.card_pool_id = s_1.card_pool_id)))
            GROUP BY cpc_1.card_id
          ), snapshot_ids AS (
           SELECT cpc_1.card_id,
              array_agg(DISTINCT s_1.id ORDER BY s_1.id) AS snapshot_ids
             FROM (card_pools_cards cpc_1
               JOIN snapshots s_1 ON ((cpc_1.card_pool_id = s_1.card_pool_id)))
            GROUP BY cpc_1.card_id
          )
   SELECT p.id,
      p.card_id,
      cc.id AS card_cycle_id,
      cc.name AS card_cycle_name,
      p.card_set_id,
      cs.name AS card_set_name,
      p.flavor,
      p.display_illustrators,
      p."position",
      p.quantity,
      p.date_release,
      c.layout_id,
      p.created_at,
      p.updated_at,
      c.additional_cost,
      c.advanceable,
      c.advancement_requirement,
      c.agenda_points,
      c.base_link,
      c.card_type_id,
      c.cost,
      c.faction_id,
      c.gains_subroutines,
      c.influence_cost,
      c.interrupt,
      c.is_unique,
      c.link_provided,
      c.memory_cost,
      c.mu_provided,
      c.num_printed_subroutines,
      c.on_encounter_effect,
      c.performs_trace,
      c.recurring_credits_provided,
      c.side_id,
      c.strength,
      c.stripped_text,
      c.stripped_title,
      c.trash_ability,
      c.trash_cost,
      COALESCE(csi.card_subtype_ids, ARRAY[]::text[]) AS card_subtype_ids,
      COALESCE(csn.lower_card_subtype_names, ARRAY[]::text[]) AS lower_card_subtype_names,
      COALESCE(csn.card_subtype_names, ARRAY[]::text[]) AS card_subtype_names,
      cp.printing_ids,
      array_length(cp.printing_ids, 1) AS num_printings,
      COALESCE(ccs.card_cycle_ids, (ARRAY[]::text[])::character varying[]) AS card_cycle_ids,
      COALESCE(ccs.card_cycle_names, ARRAY[]::text[]) AS card_cycle_names,
      COALESCE(css.card_set_ids, (ARRAY[]::text[])::character varying[]) AS card_set_ids,
      COALESCE(css.card_set_names, ARRAY[]::text[]) AS card_set_names,
      COALESCE(i.illustrator_ids, (ARRAY[]::text[])::character varying[]) AS illustrator_ids,
      COALESCE(i.illustrator_names, (ARRAY[]::text[])::character varying[]) AS illustrator_names,
      COALESCE(r.restriction_ids, (ARRAY[]::text[])::character varying[]) AS restriction_ids,
      (r.restriction_ids IS NOT NULL) AS in_restriction,
      COALESCE(r_b.restrictions_banned, ARRAY[]::text[]) AS restrictions_banned,
      COALESCE(r_g_p.restrictions_global_penalty, ARRAY[]::text[]) AS restrictions_global_penalty,
      COALESCE(r_p.restrictions_points, ARRAY[]::text[]) AS restrictions_points,
      COALESCE(r_r.restrictions_restricted, ARRAY[]::text[]) AS restrictions_restricted,
      COALESCE(r_u_f_c.restrictions_universal_faction_cost, ARRAY[]::text[]) AS restrictions_universal_faction_cost,
      COALESCE(f.format_ids, ARRAY[]::text[]) AS format_ids,
      COALESCE(cpc.card_pool_ids, ARRAY[]::text[]) AS card_pool_ids,
      COALESCE(s.snapshot_ids, (ARRAY[]::text[])::character varying[]) AS snapshot_ids,
      c.attribution,
      c.deck_limit,
      c.display_subtypes,
      c.influence_limit,
      c.minimum_deck_size,
      c.rez_effect,
      c.text,
      c.title
     FROM ((((((((((((((((((printings p
       JOIN cards c ON ((p.card_id = (c.id)::text)))
       JOIN card_cycles_summary ccs ON (((c.id)::text = (ccs.id)::text)))
       JOIN card_sets_summary css ON (((c.id)::text = (css.id)::text)))
       JOIN card_sets cs ON ((p.card_set_id = (cs.id)::text)))
       JOIN card_cycles cc ON ((cs.card_cycle_id = (cc.id)::text)))
       LEFT JOIN card_subtype_ids csi ON (((c.id)::text = csi.card_id)))
       LEFT JOIN card_subtype_names csn ON (((c.id)::text = csn.card_id)))
       JOIN card_printing_ids cp ON ((p.card_id = cp.card_id)))
       LEFT JOIN illustrators i ON (((p.id)::text = (i.printing_id)::text)))
       LEFT JOIN card_restriction_ids r ON ((p.card_id = (r.card_id)::text)))
       LEFT JOIN restrictions_banned_summary r_b ON ((p.card_id = r_b.card_id)))
       LEFT JOIN restrictions_global_penalty_summary r_g_p ON ((p.card_id = r_g_p.card_id)))
       LEFT JOIN restrictions_points_summary r_p ON ((p.card_id = r_p.card_id)))
       LEFT JOIN restrictions_restricted_summary r_r ON ((p.card_id = r_r.card_id)))
       LEFT JOIN restrictions_universal_faction_cost_summary r_u_f_c ON ((p.card_id = r_u_f_c.card_id)))
       LEFT JOIN format_ids f ON ((p.card_id = f.card_id)))
       LEFT JOIN card_pool_ids cpc ON ((p.card_id = cpc.card_id)))
       LEFT JOIN snapshot_ids s ON ((p.card_id = s.card_id)));
  SQL
end
