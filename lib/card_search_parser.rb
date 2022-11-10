require 'parslet'

class CardSearchParser < Parslet::Parser
  rule(:spaces) { match('\s').repeat(1) }
  rule(:spaces?) { spaces.maybe }

  rule(:quoted_string) { double_quoted_string | single_quoted_string }
  rule(:double_quoted_string) {
    str('"') >> (
      str('"').absent? >> any
    ).repeat.as(:string) >> str('"')
  }
  rule(:single_quoted_string) {
    str("'") >> (
      str("'").absent? >> any
    ).repeat.as(:string) >> str("'")
  }

  rule(:bare_string) {
    match('[!\w-]').repeat(1).as(:string)
  }
  rule(:string) { quoted_string | bare_string }

  rule(:regex) { # /(((\\\/)|\\)[^\/])*/
    str('/') >> (
      (str('\\/') |
      str('\\')) |
      match('[^/]')
    ).repeat.as(:regex) >> str('/')
  }

  # Note that while this list should generally be kept sorted, an entry that is a prefix of
  # a later entry will clobber the later entries and throw an error parsing text with the later entries.
  rule(:keyword) {
    str('additional_cost') |
    str('advanceable') |
    str('advancement_cost') |
    str('agenda_points') |
    str('attribution') |
    str('base_link') |
    str('card_cycle') |
    str('card_pool') |
    str('card_set') |
    str('card_subtype_id') |
    str('card_subtype') |
    str('card_type') |
    str('cost') |
    str('eternal_points') |
    str('faction') |
    str('format') |
    str('gains_subroutines') |
    str('has_global_penalty') |
    str('illustrator') |
    str('in_restriction') |
    str('influence_cost') |
    str('interrupt') |
    str('is_banned') |
    str('is_restricted') |
    str('is_unique') |
    str('link_provided') |
    str('memory_usage') |
    str('mu_provided') |
    str('num_printed_subroutines') |
    str('num_printings') |
    str('on_encounter_effect') |
    str('performs_trace') |
    str('printing_id') |
    str('recurring_credits_provided') |
    str('restriction_id') |
    str('side') |
    str('snapshot') |
    str('strength') |
    str('text') |
    str('title') |
    str('trash_ability') |
    str('trash_cost') |
    str('universal_faction_cost') |
    # Single letter 'short codes'
    match('[_abcdefghilmnoprstuvxyz]')
  }

  rule(:pair) { keyword.as(:keyword) >> operator.as(:operator) >> value_ors.as(:values) }
  rule(:operator) { str('<=') | str('>=') | match('[:!<>]') }
  rule(:value_ors) { (value_ands >> (str('|') >> value_ands).repeat).as(:value_ors) }
  rule(:value_ands) { (value >> (str('&') >> value).repeat).as(:value_ands) }
  rule(:value) { value_bracketed | regex | string }
  rule(:value_bracketed) { str('(') >> value_ors >> str(')') }

  rule(:unary) { (str('-') >> term).as(:negate) | term }
  rule(:term) { pair | singular | bracketed }
  rule(:singular) { (regex | string).as(:singular) }
  rule(:bracketed) { str('(') >> expr >> str(')') }

  rule(:ands) { (unary >> conjunction.repeat).as(:ands) }
  rule(:conjunction) {
    (spaces >> str('and') >> spaces >> unary) |
    (spaces >> str('or ').absent? >> unary)
  }

  rule(:ors) { (ands >> disjunction.repeat).as(:ors) }
  rule(:disjunction) { spaces >> str('or') >> spaces >> ands }

  rule(:expr) { ors }

  rule(:query) { expr }
  root :query
end
