WITH cards_cross_restrictions_and_snapshots AS (
    SELECT
        cards.id as card_id,
        restrictions.id as restriction_id,
        snapshots.id as snapshot_id,
        snapshots.format_id as format_id,
        snapshots.card_pool_id as card_pool_id,
        snapshots.date_start as snapshot_date_start
    FROM
        cards, restrictions JOIN snapshots ON restrictions.id = snapshots.restriction_id
)
SELECT
    cards_cross_restrictions_and_snapshots.format_id,
    cards_cross_restrictions_and_snapshots.card_pool_id,
    cards_cross_restrictions_and_snapshots.snapshot_id,
    cards_cross_restrictions_and_snapshots.snapshot_date_start,
    cards_cross_restrictions_and_snapshots.restriction_id,
    cards_cross_restrictions_and_snapshots.card_id,
    CASE WHEN restrictions_cards_banned.restriction_id IS NOT NULL THEN true ELSE false END AS is_banned,
    CASE WHEN restrictions_cards_restricted.restriction_id IS NOT NULL THEN true ELSE false END AS is_restricted,
    COALESCE(restrictions_cards_points.value, 0) AS eternal_points,
    COALESCE(restrictions_cards_global_penalty.value, 0) AS global_penalty,
    COALESCE(restrictions_cards_universal_faction_cost.value, 0) AS universal_faction_cost
FROM
    cards_cross_restrictions_and_snapshots
    LEFT OUTER JOIN restrictions_cards_banned ON
        restrictions_cards_banned.restriction_id = cards_cross_restrictions_and_snapshots.restriction_id
        AND restrictions_cards_banned.card_id = cards_cross_restrictions_and_snapshots.card_id
    LEFT OUTER JOIN restrictions_cards_points ON
        restrictions_cards_points.restriction_id = cards_cross_restrictions_and_snapshots.restriction_id
        AND restrictions_cards_points.card_id = cards_cross_restrictions_and_snapshots.card_id
    LEFT OUTER JOIN restrictions_cards_global_penalty ON
        restrictions_cards_global_penalty.restriction_id = cards_cross_restrictions_and_snapshots.restriction_id
        AND restrictions_cards_global_penalty.card_id = cards_cross_restrictions_and_snapshots.card_id
    LEFT OUTER JOIN restrictions_cards_restricted ON
        restrictions_cards_restricted.restriction_id = cards_cross_restrictions_and_snapshots.restriction_id
        AND restrictions_cards_restricted.card_id = cards_cross_restrictions_and_snapshots.card_id
    LEFT OUTER JOIN restrictions_cards_universal_faction_cost ON
        restrictions_cards_universal_faction_cost.restriction_id = cards_cross_restrictions_and_snapshots.restriction_id
        AND restrictions_cards_universal_faction_cost.card_id = cards_cross_restrictions_and_snapshots.card_id
;
