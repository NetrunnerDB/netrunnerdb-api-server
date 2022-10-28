WITH
card_subtype_ids AS (
    SELECT
        card_id,
        ARRAY_AGG(
            card_subtype_id
            ORDER BY
                1
        ) as card_subtype_ids
    FROM
        cards_card_subtypes
    GROUP BY
        card_id
),
card_subtype_names AS (
    SELECT
        ccs.card_id,
        -- lower used for filtering
        ARRAY_AGG(
            LOWER(cs.name) ORDER BY LOWER(cs.name)
        ) as lower_card_subtype_names,
        -- proper case used for display
        ARRAY_AGG(
            cs.name ORDER BY cs.name
        ) as card_subtype_names
    FROM
        cards_card_subtypes ccs
        JOIN card_subtypes cs ON ccs.card_subtype_id = cs.id
    GROUP BY
        ccs.card_id
),
card_printing_ids AS (
    SELECT
        card_id,
        ARRAY_AGG(
            id ORDER BY date_release DESC
        ) as printing_ids
    FROM
        printings
    GROUP BY
        card_id
)
SELECT
    p.id,
    p.card_id,
    cc.id as card_cycle_id,
    cc.name as card_cycle_name,
    p.card_set_id,
    cs.name as card_set_name,
    p.printed_text,
    p.stripped_printed_text,
    p.printed_is_unique,
    p.flavor,
    p.display_illustrators,
    p.position,
    p.quantity,
    p.date_release,
    p.created_at,
    p.updated_at,
--        'card_pool' => 'card_pools_cards.card_pool_id',
--
--        'card_subtype' => 'card_subtypes.name',
--        card_subtypes.name,
--
--        'card_cycle' => 'card_sets.card_cycle_id',
--        'c' => 'card_sets.card_cycle_id',
--
--        'eternal_points' => 'unified_restrictions.eternal_points',
--        'format' => 'unified_restrictions.format_id',
--        'has_global_penalty' => 'unified_restrictions.has_global_penalty',
--        'in_restriction' => 'unified_restrictions.in_restriction',
--        'is_banned' => 'unified_restrictions.is_banned',
--        'is_restricted' => 'unified_restrictions.is_restricted',
--        'restriction_id' => 'unified_restrictions.restriction_id',
--        'universal_faction_cost' => 'unified_restrictions.universal_faction_cost',
--
--        'i' => 'illustrators.name',
--        'illustrator' => 'illustrators.name',

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
        COALESCE(csi.card_subtype_ids, ARRAY [] :: text []) as card_subtype_ids,
        COALESCE(csn.lower_card_subtype_names, ARRAY [] :: text []) as lower_card_subtype_names,
        COALESCE(csn.card_subtype_names, ARRAY [] :: text []) as card_subtype_names,
        cp.printing_ids
 FROM
    printings p
    INNER JOIN cards c ON p.card_id = c.id
    INNER JOIN card_sets cs ON p.card_set_id = cs.id
    INNER JOIN card_cycles cc ON cs.card_cycle_id = cc.id
    LEFT JOIN card_subtype_ids csi ON c.id = csi.card_id
    LEFT JOIN card_subtype_names csn ON c.id = csn.card_id
    INNER JOIN card_printing_ids cp ON p.card_id = cp.card_id
 ;
