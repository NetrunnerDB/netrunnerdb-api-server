require 'parslet'

# TODO(plural): Add support for | in : and ! operators .
class SearchParser < Parslet::Parser
  rule(:spaces) { match('\s').repeat(1) }
  rule(:spaces?) { spaces.maybe }
  rule(:bare_string) {
      match('[!\w-]').repeat(1).as(:string)
  }
  rule(:quoted_string) {
    str('"') >> (
      str('"').absent? >> any
    ).repeat.as(:string) >> str('"')
  }
  rule(:string) {
    spaces? >> (bare_string | quoted_string) >> spaces?
  }
  # Note that while this list should generally be kept sorted, an entry that is a prefix of
  # a later entry will clobber the later entries and throw an error parsing text with the later entries.
  rule(:keyword) {
    str('advancement_cost') |
    str('agenda_points') |
    str('base_link') |
    str('card_cycle') |
    str('card_pool') |
    str('card_set') |
    str('card_subtype') |
    str('card_type') |
    str('cost') |
    str('eternal_points') |
    str('faction') |
    str('flavor_text') |
    str('format') |
    str('global_penalty') |
    str('illustrator') |
    str('influence_cost') |
    str('is_banned') |
    str('is_restricted') |
    str('is_unique') |
    str('memory_usage') |
    str('quantity_in_card_set') |
    str('release_date') |
    str('restriction_id') |
    str('side') |
    str('strength') |
    str('text') |
    str('title') |
    str('trash_cost') |
    str('universal_faction_cost') |
    # Single letter 'short codes'
    match('[_abcdefghilmnoprstuvxyz]')
  }
  rule(:match_type) { str('<=') | str('>=') | match('[:!<>]') }
  rule(:operator) { keyword >> match_type}
  rule(:search_term) { keyword.as(:keyword) >> match_type.as(:match_type) >> (string).as(:value) }
  rule(:query) {
    (spaces? >> (search_term.as(:search_term) | string)  >> spaces?).repeat.as(:fragments)
  }
  root :query
end
