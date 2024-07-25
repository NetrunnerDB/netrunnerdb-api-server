# frozen_string_literal: true

require 'minitest/autorun'
require 'parslet/convenience'

class SearchParserTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  def test_parses_a_keyword
    input = %(t)
    parser = SearchParser.new.keyword
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_fails_with_non_keyword
    inputs = [%(...), %(1)]
    parser = SearchParser.new.keyword
    inputs.each do |i|
      tree = nil
      begin
        tree = parser.parse(i)
        assert_not(true, 'parser unexpectedly passed')
      rescue Parslet::ParseFailed
        assert tree.nil?
      end
    end
  end

  def test_parses_an_operator
    operators = [':', '!', '>', '<', '<=', '>=']
    parser = SearchParser.new.operator
    operators.each do |o|
      tree = parser.parse_with_debug(o)
      assert_not_equal nil, tree
    end
  end

  def test_fails_with_non_operator
    inputs = ['a', '?', '&', '(', '-']
    parser = SearchParser.new.operator
    inputs.each do |o|
      tree = nil
      begin
        tree = parser.parse(o)
        assert_not(true, 'parser unexpectedly passed')
      rescue Parslet::ParseFailed
        assert tree.nil?
      end
    end
  end

  def test_parses_a_simple_value
    values = %w[a weyland-consortium 1 01-01-1970]
    parser = SearchParser.new.values
    values.each do |v|
      tree = parser.parse_with_debug(v)
      assert_not_equal nil, tree
    end
  end

  def test_parses_a_regex_value
    input = '/^n/'
    parser = SearchParser.new.values
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_parses_a_quote_value
    values = [%("double"), "'single'", %("double quotes"), %('single quotes')]
    values.each do |v|
      parser = SearchParser.new.values
      tree = parser.parse_with_debug(v)
      assert_not_equal nil, tree
    end
  end

  def test_parses_combined_values
    values = ['a|b', 'a&b', '(a)', 'a|(b&c)', '(a&b)|(c&d)']
    values.each do |v|
      parser = SearchParser.new.value_ors
      tree = parser.parse_with_debug(v)
      assert_not_equal nil, tree
    end
  end

  def test_parses_a_pair
    keywords = %w[a b c]
    operators = [':', '!', '>', '<', '<=', '>=']
    values = ['a', '/.*[^ab]$/', %{(a|"b")&(c|' d ')}]
    keywords.each do |k|
      operators.each do |o|
        values.each do |v|
          parser = SearchParser.new.pair
          tree = parser.parse_with_debug("#{k}#{o}#{v}")
          assert_not_equal nil, tree
        end
      end
    end
  end

  def test_parses_a_query
    input = %(f:weyland-consortium t!"operation" n<=1)
    parser = SearchParser.new.query
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_parses_a_query_and_some_words
    input = %(a b test run f:weyland-consortium t!"operation" n<=1)
    parser = SearchParser.new.query
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_parses_a_bare_string
    input = %(hello-world)
    parser = SearchParser.new.bare_string
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_parses_a_quoted_string
    input = %("hello world")
    parser = SearchParser.new.quoted_string
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_root_parses_a_query
    input = %(f:weyland-consortium t!"operation" n<=1)
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_root_parses_a_bare_word
    input = %( siphon      )
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_root_parses_a_quoted_word
    input = %( "sure gamble")
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_string
    inputs = [%("sure gamble"), %(diversion)]
    inputs.each do |s|
      parser = SearchParser.new.string
      tree = parser.parse_with_debug(s)
      assert_not_equal nil, tree
    end
  end

  def test_root_strings
    input = %( "sure gamble"         diversion         )
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end

  def test_root_parses_a_query_and_some_words
    input = %("bean" f:weyland-consortium t!"operation"   royalties  n<=1 )
    parser = SearchParser.new
    tree = parser.parse_with_debug(input)
    assert_not_equal nil, tree
  end
end
