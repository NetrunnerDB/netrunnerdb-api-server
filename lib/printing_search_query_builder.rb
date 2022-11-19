require_relative 'search_query_builder'

class PrintingSearchQueryBuilder < SearchQueryBuilder

  # TODO(plural): figure out how to do name matches that are LIKEs over elements of an array.
  # format should implicitly use the currently active card pool and restriction lists unless another is specified.
  @fields = [
    FieldData.new(:array, 'unified_printings.card_cycle_ids', ['card_cycle']),
    FieldData.new(:array, 'unified_printings.card_pool_ids', ['card_pool']),
    FieldData.new(:array, 'unified_printings.card_set_ids', ['card_set']),
    FieldData.new(:array, 'unified_printings.lower_card_subtype_names', ['card_subtype']),
    FieldData.new(:array, 'unified_printings.card_subtype_ids', ['card_subtype_id']),
    FieldData.new(:array, 'unified_printings.restrictions_points', ['eternal_points']),
    FieldData.new(:array, 'unified_printings.format_ids', ['format']),
    FieldData.new(:array, 'unified_printings.restrictions_global_penalty', ['has_global_penalty']),
    FieldData.new(:array, 'unified_printings.restrictions_global_penalty', ['illustrator_id']),
    FieldData.new(:array, 'unified_printings.restrictions_banned', ['is_banned']),
    FieldData.new(:array, 'unified_printings.restrictions_restricted', ['is_restricted']),
    FieldData.new(:array, 'unified_printings.restriction_ids', ['restriction_id']),
    FieldData.new(:array, 'unified_printings.snapshot_ids', ['snapshot']),
    FieldData.new(:array, 'unified_printings.restrictions_universal_faction_cost', ['universal_faction_cost']),
    FieldData.new(:boolean, 'unified_printings.additional_cost', ['additional_cost']),
    FieldData.new(:boolean, 'unified_printings.advanceable', ['advanceable']),
    FieldData.new(:boolean, 'unified_printings.gains_subroutines', ['gains_subroutines']),
    FieldData.new(:boolean, 'unified_printings.in_restriction', ['in_restriction']),
    FieldData.new(:boolean, 'unified_printings.interrupt', ['interrupt']),
    FieldData.new(:boolean, 'unified_printings.is_unique', ['is_unique', 'u']),
    FieldData.new(:boolean, 'unified_printings.on_encounter_effect', ['on_encounter_effect']),
    FieldData.new(:boolean, 'unified_printings.performs_trace', ['performs_trace']),
    FieldData.new(:boolean, 'unified_printings.trash_ability', ['trash_ability']),
    FieldData.new(:date, 'unified_printings.date_release', ['release_date', 'date_release', 'r']),
    FieldData.new(:integer, 'unified_printings.advancement_requirement', ['advancement_cost', 'g']),
    FieldData.new(:integer, 'unified_printings.agenda_points', ['agenda_points', 'v']),
    FieldData.new(:integer, 'unified_printings.base_link', ['base_link', 'l']),
    FieldData.new(:integer, 'unified_printings.cost', ['cost', 'o']),
    FieldData.new(:integer, 'unified_printings.influence_cost', ['influence_cost', 'n']),
    FieldData.new(:integer, 'unified_printings.link_provided', ['link_provided']),
    FieldData.new(:integer, 'unified_printings.memory_cost', ['memory_usage', 'm']),
    FieldData.new(:integer, 'unified_printings.mu_provided', ['mu_provided']),
    FieldData.new(:integer, 'unified_printings.num_printed_subroutines', ['num_printed_subroutines']),
    FieldData.new(:integer, 'unified_printings.num_printings', ['num_printings']),
    FieldData.new(:integer, 'unified_printings.quantity', ['quantity', 'y']),
    FieldData.new(:integer, 'unified_printings.recurring_credits_provided', ['recurring_credits_provided']),
    FieldData.new(:integer, 'unified_printings.strength', ['strength', 'p']),
    FieldData.new(:integer, 'unified_printings.trash_cost', ['trash_cost', 'h']),
    FieldData.new(:string, 'unified_printings.attribution', ['attribution']),
    FieldData.new(:string, 'unified_printings.card_type_id', ['card_type', 't']),
    FieldData.new(:string, 'unified_printings.faction_id', ['faction', 'f']),
    FieldData.new(:string, 'unified_printings.flavor', ['flavor', 'flavour', 'a']),
    FieldData.new(:string, 'unified_printings.display_illustrators', ['illustrator', 'i']),
    FieldData.new(:string, 'unified_printings.side_id', ['side', 'd']),
    FieldData.new(:string, 'unified_printings.stripped_text', ['text', 'x']),
    FieldData.new(:string, 'unified_printings.stripped_title', ['title', '_'])
  ]

end
