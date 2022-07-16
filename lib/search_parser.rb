require 'parslet'

class SearchParser < Parslet::Parser
    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:bare_string) {
        match('[\w-]').repeat(1).as(:string)
    }
    rule(:quoted_string) {
      str('"') >> (
        str('"').absent? >> any
      ).repeat.as(:string) >> str('"')
    }
    rule(:string) {
      spaces? >> (bare_string | quoted_string) >> spaces?
    }

    rule(:keyword) {
      str('title') | str('text') | str('flavor_text') | 
      str('card_set') | str('card_cycle') | str('card_type') | 
      str('faction') | str('card_subtype') | str('side') | 
      str('illustrator') | str('cost') | str('advancement_cost') | 
      str('base_link') | str('memory_usage') | str('influence_cost') | 
      str('strength') | str('agenda_points') | str('trash_cost') | 
      str('release_date') | str('is_unique') | str('quantity_in_card_set') | 
      str('restriction') | str('card_pool') | str('format') | 
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

