require 'minitest/autorun'
require 'parslet/convenience'
require 'search_parser'
require 'search_query_builder'

class SearchQueryBuilderTest < Minitest::Test
  def test_simple_successful_query
    input = %Q{x:trash}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(stripped_text) LIKE ?', builder.where 
    assert_equal ['%trash%'], builder.where_values
  end

  def test_simple_successful_query_with_multiple_terms
    input = %Q{x:trash cost:3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(stripped_text) LIKE ? AND cost = ?', builder.where 
    assert_equal ['%trash%', '3'], builder.where_values
  end

  def test_numeric_field_not_equal 
    input = %Q{trash_cost!3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'trash_cost != ?', builder.where 
    assert_equal ['3'], builder.where_values
  end

  def test_numeric_field_less_than
    input = %Q{trash_cost<3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'trash_cost < ?', builder.where 
    assert_equal ['3'], builder.where_values
  end

  def test_numeric_field_less_than_equal_to
    input = %Q{trash_cost<=3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'trash_cost <= ?', builder.where 
    assert_equal ['3'], builder.where_values
  end

  def test_numeric_field_greater_than
    input = %Q{trash_cost>3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'trash_cost > ?', builder.where 
    assert_equal ['3'], builder.where_values
  end

  def test_numeric_field_greater_than_equal_to
    input = %Q{trash_cost>=3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'trash_cost >= ?', builder.where 
    assert_equal ['3'], builder.where_values
  end

  def test_string_field_not_like
    input = %Q{title!sure}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%sure%'], builder.where_values
  end

  def test_boolean_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each {|op|
      input = 'is_unique%strue' % op
      builder = SearchQueryBuilder.new(input)

      assert_equal 'Invalid boolean operator "%s"' % op, builder.parse_error
      assert_equal '', builder.where
      assert_equal [], builder.where_values
    }
  end

  def test_string_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each {|op|
      input = 'title%ssure' % op
      builder = SearchQueryBuilder.new(input)

      assert_equal 'Invalid string operator "%s"' % op, builder.parse_error
      assert_equal '', builder.where
      assert_equal [], builder.where_values
    }
  end

  def test_bare_word 
    input = %Q{diversion}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(stripped_title) LIKE ?', builder.where 
    assert_equal ['%diversion%'], builder.where_values
  end

  def test_bare_word_negated 
    input = %Q{!diversion}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%diversion%'], builder.where_values
  end

  def test_quoted_string_negated 
    input = %Q{"!diversion of funds"}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%diversion of funds%'], builder.where_values
  end

  def test_bad_query_bad_operator
    builder = SearchQueryBuilder.new('w:bleargh')
    refute_equal builder.parse_error, nil
  end
end