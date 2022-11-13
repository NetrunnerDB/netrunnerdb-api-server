require 'parslet'
# require_relative "search_parser"

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
  rule(:keyword) { match('[_abcdefghilmnoprstuvxyz]').repeat(1) }

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
