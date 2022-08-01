require 'minitest/autorun'
require 'parslet/convenience'

class CardSearchParserTest < Minitest::Test
  def test_fails_with_non_keyword
    input = %Q{w}
    parser = CardSearchParser.new.keyword
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
    parser = CardSearchParser.new.keyword
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
  end

  def test_parses_a_match_type
    [':', '!', '>', '<', '<=', '>='].each {|i|
        parser = CardSearchParser.new.match_type
        tree = parser.parse_with_debug(i)
        refute_equal nil, tree
    }
  end

  def test_parses_an_operator
    ['a', 'b', 'c'].each {|k|
        [':', '!', '>', '<'].each {|i|
            parser = CardSearchParser.new.operator
            tree = parser.parse_with_debug('%s%s' % [k, i])
            refute_equal nil, tree
        }
    }
  end

  def test_parses_a_search_term_with_a_bare_string
    input = %Q{f:weyland-consortium}
    parser = CardSearchParser.new.search_term
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {keyword: "f", match_type: ":", value: {string: "weyland-consortium"}}
    assert_equal expected, tree
  end

  def test_parses_a_query
    input = %Q{f:weyland-consortium t!"operation" n<=1}
    parser = CardSearchParser.new.query
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
    parser = CardSearchParser.new.bare_string
    tree = parser.parse_with_debug(input)

    expected = {string: "hello-world"}
    assert_equal expected, tree
  end

  def test_parses_a_quoted_string
    input = %Q{"hello world"}
    parser = CardSearchParser.new.quoted_string
    tree = parser.parse_with_debug(input)

    expected = {string: "hello world"}
    assert_equal expected, tree
  end

  def test_root_parses_a_query
    input = %Q{ f:weyland-consortium t!"operation" n<=1}
    parser = CardSearchParser.new
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
    parser = CardSearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [{ string: "siphon" }]}
    assert_equal expected, tree
  end

  def test_root_parses_a_quoted_word
    input = %Q{ "sure gamble"}
    parser = CardSearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [{ string: "sure gamble" }]}
    assert_equal expected, tree
  end

  def test_string
    [%Q{ "sure gamble"}, %Q{diversion}].each{ |s|
      parser = CardSearchParser.new.string
      tree = parser.parse_with_debug(s)
      refute_equal nil, tree
      expected = {string: s.gsub(/["']/, '').strip}
      assert_equal expected, tree
    }
  end

  def test_root_strings
    input = %Q{ "sure gamble"         diversion         }
    parser = CardSearchParser.new
    tree = parser.parse_with_debug(input)
    refute_equal nil, tree
    expected = {fragments: [{ string: "sure gamble" }, { string: "diversion" }]}
    assert_equal expected, tree
  end

  def test_root_parses_a_query_and_some_words
    input = %Q{"bean" f:weyland-consortium t!"operation"   royalties  n<=1 }
    parser = CardSearchParser.new
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
end
