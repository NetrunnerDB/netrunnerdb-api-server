# frozen_string_literal: true

require 'parslet'

# Search grammer parser for NRDB search query syntax.
#
# This provides an AST to inspect, if valid, but SearchQueryBuilder turns this into SQL.
class SearchParser < Parslet::Parser
  rule(:spaces) { match('\p{Space Separator}').repeat(1) }
  rule(:spaces?) { spaces.maybe }

  rule(:quoted_string) { double_quoted_string | single_quoted_string }
  rule(:double_quoted_string) do
    str('"') >> (
      str('"').absent? >> any
    ).repeat.as(:string) >> str('"')
  end
  rule(:single_quoted_string) do
    str("'") >> (
      str("'").absent? >> any
    ).repeat.as(:string) >> str("'")
  end

  rule(:bare_string) do
    match('[-!_\p{Letter}\p{Number}]').repeat(1).as(:string)
  end
  rule(:string) { quoted_string | bare_string }

  rule(:regex) do # /(((\\\/)|\\)[^\/])*/
    str('/') >> (
      (str('\\/') |
      str('\\')) |
      match('[^/]')
    ).repeat.as(:regex) >> str('/')
  end

  rule(:keyword) { match('[_a-z]').repeat(1) }

  rule(:pair) { keyword.as(:keyword) >> operator.as(:operator) >> values.as(:values) }
  rule(:values) { value_ors }
  rule(:operator) { str('<=') | str('>=') | match('[:!<>]') }
  rule(:value_ors) { (value_ands >> (str('|') >> value_ands).repeat).as(:value_ors) }
  rule(:value_ands) { (value >> (str('&') >> value).repeat).as(:value_ands) }
  rule(:value) { value_bracketed | regex | string }
  rule(:value_bracketed) { str('(') >> value_ors >> str(')') }

  rule(:unary) { (match('[!-]') >> term).as(:negate) | term }
  rule(:term) { pair | singular | bracketed }
  rule(:singular) { (regex | string).as(:singular) }
  rule(:bracketed) { str('(') >> expr.as(:bracketed) >> str(')') }

  rule(:ands) { (unary >> conjunction.repeat).as(:ands) }
  rule(:conjunction) do
    (spaces >> str('and') >> spaces >> unary) |
      (spaces >> str('or ').absent? >> unary)
  end

  rule(:ors) { (ands >> disjunction.repeat).as(:ors) }
  rule(:disjunction) { spaces >> str('or') >> spaces >> ands }

  rule(:expr) { spaces? >> ors >> spaces? }

  rule(:query) { expr }
  root :query
end
