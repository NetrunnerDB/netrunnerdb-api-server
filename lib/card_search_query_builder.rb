require_relative 'search_query_builder'

class CardSearchQueryBuilder < SearchQueryBuilder

  # TODO(plural): figure out how to do name matches that are LIKEs over elements of an array.
  # format should implicitly use the currently active card pool and restriction lists unless another is specified.
  @fields = [
    FieldData.new(:array, 'unified_cards.card_cycle_ids', ['card_cycle']),
    FieldData.new(:array, 'unified_cards.card_pool_ids', ['card_pool']),
    FieldData.new(:array, 'unified_cards.card_set_ids', ['card_set']),
    FieldData.new(:array, 'unified_cards.lower_card_subtype_names', ['card_subtype']),
    FieldData.new(:array, 'unified_cards.card_subtype_ids', ['card_subtype_id']),
    FieldData.new(:array, 'unified_cards.restrictions_points', ['eternal_points']),
    FieldData.new(:array, 'unified_cards.format_ids', ['format']),
    FieldData.new(:array, 'unified_cards.restrictions_global_penalty', ['has_global_penalty']),
    FieldData.new(:array, 'unified_cards.restrictions_banned', ['is_banned']),
    FieldData.new(:array, 'unified_cards.restrictions_restricted', ['is_restricted']),
    FieldData.new(:array, 'unified_cards.printing_ids', ['printing_id']),
    FieldData.new(:array, 'unified_cards.restriction_ids', ['restriction_id']),
    FieldData.new(:array, 'unified_cards.snapshot_ids', ['snapshot']),
    FieldData.new(:array, 'unified_cards.restrictions_universal_faction_cost', ['universal_faction_cost']),
    FieldData.new(:boolean, 'unified_cards.additional_cost', ['additional_cost']),
    FieldData.new(:boolean, 'unified_cards.advanceable', ['advanceable']),
    FieldData.new(:boolean, 'unified_cards.gains_subroutines', ['gains_subroutines']),
    FieldData.new(:boolean, 'unified_cards.in_restriction', ['in_restriction']),
    FieldData.new(:boolean, 'unified_cards.interrupt', ['interrupt']),
    FieldData.new(:boolean, 'unified_cards.is_unique', ['is_unique']),
    FieldData.new(:boolean, 'unified_cards.on_encounter_effect', ['on_encounter_effect']),
    FieldData.new(:boolean, 'unified_cards.performs_trace', ['performs_trace']),
    FieldData.new(:boolean, 'unified_cards.trash_ability', ['trash_ability']),
    FieldData.new(:integer, 'unified_cards.advancement_requirement', ['advancement_cost', 'g']),
    FieldData.new(:integer, 'unified_cards.agenda_points', ['agenda_points', 'v']),
    FieldData.new(:integer, 'unified_cards.base_link', ['base_link', 'l']),
    FieldData.new(:integer, 'unified_cards.cost', ['cost', 'o']),
    FieldData.new(:integer, 'unified_cards.influence_cost', ['influence_cost', 'n']),
    FieldData.new(:integer, 'unified_cards.link_provided', ['link_provided']),
    FieldData.new(:integer, 'unified_cards.memory_cost', ['memory_usage', 'm']),
    FieldData.new(:integer, 'unified_cards.mu_provided', ['mu_provided']),
    FieldData.new(:integer, 'unified_cards.num_printed_subroutines', ['num_printed_subroutines']),
    FieldData.new(:integer, 'unified_cards.num_printings', ['num_printings']),
    FieldData.new(:integer, 'unified_cards.recurring_credits_provided', ['recurring_credits_provided']),
    FieldData.new(:integer, 'unified_cards.strength', ['strength', 'p']),
    FieldData.new(:integer, 'unified_cards.trash_cost', ['trash_cost', 'h']),
    FieldData.new(:string, 'unified_cards.attribution', ['attribution']),
    FieldData.new(:string, 'unified_cards.card_type_id', ['card_type', 't']),
    FieldData.new(:string, 'unified_cards.faction_id', ['faction', 'f']),
    FieldData.new(:string, 'unified_cards.side_id', ['side', 'd']),
    FieldData.new(:string, 'unified_cards.stripped_text', ['text', 'x']),
    FieldData.new(:string, 'unified_cards.stripped_title', ['title', '_'])
  ]

end
