require 'minitest/autorun'
require 'parslet/convenience'
require 'search_parser'

class SearchParserTest < Minitest::Test
  def test_fails_with_non_keyword
    input = %Q{w}
    parser = SearchParser.new.keyword
    tree = nil
    begin
      tree = parser.parse(input)
      refute(true, 'parser unexpectedly passed')
    rescue Parslet::ParseFailed => e
      assert tree.nil?
    end
  end

  def test_parses_a_keyword 
    input = %Q{t}
    parser = SearchParser.new.keyword
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_parses_a_match_type
    [':', '!', '>', '<', '<=', '>='].each {|i|
        parser = SearchParser.new.match_type
        tree = parser.parse_with_debug(i)
        refute_equal nil, tree
    }
  end

  def test_parses_an_operator
    ['a', 'b', 'c'].each {|k|
        [':', '!', '>', '<'].each {|i|
            parser = SearchParser.new.operator
            tree = parser.parse_with_debug('%s%s' % [k, i])
            refute_equal nil, tree
        }
    }
  end

  def test_parses_a_search_term_with_a_bare_string
    input = %Q{f:weyland-consortium}
    parser = SearchParser.new.search_term
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {keyword: "f", match_type: ":", value: {string: "weyland-consortium"}}
    assert_equal expected, tree
  end

  def test_parses_a_query
    input = %Q{f:weyland-consortium t!"operation" n<=1}
    parser = SearchParser.new.query
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [
      {search_term: {keyword: "f", match_type: ":", value: {string: "weyland-consortium"}}},
      {search_term: {keyword: "t", match_type: "!", value: {string: "operation"}}},
      {search_term: {keyword: "n", match_type: "<=", value: {string: "1"}}}
    ]}

    assert_equal expected, tree
  end

  def test_parses_a_bare_string
    input = %Q{hello-world}
    parser = SearchParser.new.bare_string
    tree = parser.parse_with_debug(input)

    expected = {string: "hello-world"}
    assert_equal expected, tree
  end

  def test_parses_a_quoted_string
    input = %Q{"hello world"}
    parser = SearchParser.new.quoted_string
    tree = parser.parse_with_debug(input)

    expected = {string: "hello world"}
    assert_equal expected, tree
  end

  def test_root_parses_a_query
    input = %Q{ f:weyland-consortium t!"operation" n<=1}
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [
      {search_term: {keyword: "f", match_type: ":", value: {string: "weyland-consortium"}}},
      {search_term: {keyword: "t", match_type: "!", value: {string: "operation"}}},
      {search_term: {keyword: "n", match_type: "<=", value: {string: "1"}}}
    ]}
    assert_equal expected, tree
  end

  def test_root_parses_a_bare_word
    input = %Q{ siphon      }
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [{ string: "siphon" }]}
    assert_equal expected, tree
  end

  def test_root_parses_a_quoted_word
    input = %Q{ "sure gamble"}
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [{ string: "sure gamble" }]}
    assert_equal expected, tree
  end

  def test_string
    [%Q{ "sure gamble"}, %Q{diversion}].each{ |s|
      parser = SearchParser.new.string
      tree = parser.parse_with_debug(s)
      refute_equal nil, tree
      expected = {string: s.gsub(/["']/, '').strip}
      assert_equal expected, tree
    }
  end

  def test_root_strings
    input = %Q{ "sure gamble"         diversion         }
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [{ string: "sure gamble" }, { string: "diversion" }]}
    assert_equal expected, tree
  end

  def test_root_parses_a_query_and_some_words
    input = %Q{"bean" f:weyland-consortium t!"operation"   royalties  n<=1 }
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [
      {string: "bean"}, 
      {search_term: {keyword: "f", match_type: ":", value: {string: "weyland-consortium"}}},
      {search_term: {keyword: "t", match_type: "!", value: {string: "operation"}}},
      {string: "royalties"},
      {search_term: {keyword: "n", match_type: "<=", value: {string: "1"}}}
    ]}
    assert_equal expected, tree
  end

#
#  def test_parses_a_word
#    input = %Q{hello}
#    parser = SearchParser.new.string
#    tree = parser.parse_with_debug(input)
#
#    expected = {word: "hello"}
#    assert_equal expected, tree
#  end
#
#  def test_key
#    input = %Q{ hello: }
#    parser = SearchParser.new.key
#    tree = parser.parse_with_debug(input)
#    refute_equal nil, tree
#  end
#
#  def test_parses_a_key_value_pair
#    input = %Q{hello: "world"}
#    parser = SearchParser.new.key_value
#    tree = parser.parse_with_debug(input)
#    refute_equal nil, tree
#
#    actual = SearchTransformer.new.apply(tree)
#    expected = {key_value: {key: "hello", val: "world"}}
#    assert_equal expected, actual
#  end
#  def test_parses_a_key_value_pair_2
#    input = %Q{       hi: "there",}
#    parser = SearchParser.new.key_value_comma
#    tree = parser.parse_with_debug(input)
#    refute_equal nil, tree
#
#    actual = SearchTransformer.new.apply(tree)
#    expected = {key_value: {key: "hi", val: "there"}}
#    assert_equal expected, actual
#  end
#  def test_parses_multiple_key_value_pairs
#    input = %Q{hello: "world", hi: "there" }
#    parser = SearchParser.new.named_args
#    tree = parser.parse_with_debug(input)
#    refute_equal nil, tree
#  end
end
