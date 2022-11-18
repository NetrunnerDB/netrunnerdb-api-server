require 'minitest/autorun'
require 'parslet/convenience'

class SearchParserTest < Minitest::Test

  def test_parses_a_keyword
    input = %Q{t}
    parser = SearchParser.new.keyword
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_fails_with_non_keyword
    inputs = [%Q{...}, %Q{1}]
    parser = SearchParser.new.keyword
    inputs.each {|i|
      tree = nil
      begin
        tree = parser.parse(i)
        refute(true, 'parser unexpectedly passed')
      rescue Parslet::ParseFailed => e
        assert tree.nil?
      end
    }
  end

  def test_parses_an_operator
    operators = [':', '!', '>', '<', '<=', '>=']
    parser = SearchParser.new.operator
    operators.each {|o|
      tree = parser.parse_with_debug(o)
      refute_equal nil, tree
    }
  end

  def test_fails_with_non_operator
    inputs = ['a', '?', '&', '(', '-']
    parser = SearchParser.new.operator
    inputs.each {|o|
      tree = nil
      begin
        tree = parser.parse(o)
        refute(true, 'parser unexpectedly passed')
      rescue Parslet::ParseFailed => e
        assert tree.nil?
      end
    }
  end

  def test_parses_a_simple_value
    values = ['a', 'weyland-consortium', '1', '01-01-1970']
    parser = SearchParser.new.values
    values.each {|v|
      tree = parser.parse_with_debug(v)
      refute_equal nil, tree
    }
  end

  def test_parses_a_regex_value
    input = '/^n/'
    parser = SearchParser.new.values
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_parses_a_quote_value
    values = [%Q{"double"}, %q{'single'}, %Q{"double quotes"}, %Q{'single quotes'}]
    values.each {|v|
      parser = SearchParser.new.values
      tree = parser.parse_with_debug(v)
      refute_equal nil, tree
    }
  end

  def test_parses_combined_values
    values = ['a|b', 'a&b', '(a)', 'a|(b&c)', '(a&b)|(c&d)']
    values.each {|v|
      parser = SearchParser.new.value_ors
      tree = parser.parse_with_debug(v)
      refute_equal nil, tree
    }
  end

  def test_parses_a_pair
    keywords = ['a', 'b', 'c']
    operators = [':', '!', '>', '<', '<=', '>=']
    values = ['a', '/.*[^ab]$/', %Q{(a|"b")&(c|' d ')}]
    keywords.each {|k|
      operators.each {|o|
        values.each {|v|
          parser = SearchParser.new.pair
          tree = parser.parse_with_debug('%s%s%s' % [k, o, v])
          refute_equal nil, tree
        }
      }
    }
  end

  def test_parses_a_query
    input = %Q{f:weyland-consortium t!"operation" n<=1}
    parser = SearchParser.new.query
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_parses_a_query_and_some_words
    input = %Q{a b test run f:weyland-consortium t!"operation" n<=1}
    parser = SearchParser.new.query
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_parses_a_bare_string
    input = %Q{hello-world}
    parser = SearchParser.new.bare_string
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_parses_a_quoted_string
    input = %Q{"hello world"}
    parser = SearchParser.new.quoted_string
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_root_parses_a_query
    input = %Q{f:weyland-consortium t!"operation" n<=1}
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_root_parses_a_bare_word
    input = %Q{ siphon      }
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_root_parses_a_quoted_word
    input = %Q{ "sure gamble"}
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_string
    inputs = [%Q{"sure gamble"}, %Q{diversion}]
    inputs.each{ |s|
      parser = SearchParser.new.string
      tree = parser.parse_with_debug(s)
      refute_equal nil, tree
    }
  end

  def test_root_strings
    input = %Q{ "sure gamble"         diversion         }
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_root_parses_a_query_and_some_words
    input = %Q{"bean" f:weyland-consortium t!"operation"   royalties  n<=1 }
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end
end
