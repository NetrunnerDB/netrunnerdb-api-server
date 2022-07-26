require 'minitest/autorun'
require 'parslet/convenience'
require 'search_parser'
require 'search_query_builder'

class SearchQueryBuilderTest < Minitest::Test
  def test_simple_successful_query
    input = %Q{x:trash}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_text) LIKE ?', builder.where 
    assert_equal ['%trash%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_simple_successful_query_with_multiple_terms
    input = %Q{x:trash cost:3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_text) LIKE ? AND cards.cost = ?', builder.where 
    assert_equal ['%trash%', '3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_not_equal 
    input = %Q{trash_cost!3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost != ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_less_than
    input = %Q{trash_cost<3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost < ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_less_than_equal_to
    input = %Q{trash_cost<=3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost <= ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_greater_than
    input = %Q{trash_cost>3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost > ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_greater_than_equal_to
    input = %Q{trash_cost>=3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost >= ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_string_field_not_like
    input = %Q{title!sure}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%sure%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_boolean_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each {|op|
      input = 'is_unique%strue' % op
      builder = SearchQueryBuilder.new(input)

      assert_equal 'Invalid boolean operator "%s"' % op, builder.parse_error
      assert_equal '', builder.where
      assert_equal [], builder.where_values
      assert_equal [], builder.left_joins
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
      assert_equal [], builder.left_joins
    }
  end

  def test_bare_word 
    input = %Q{diversion}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) LIKE ?', builder.where 
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bare_word_negated 
    input = %Q{!diversion}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_quoted_string_negated 
    input = %Q{"!diversion of funds"}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%diversion of funds%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_query_bad_operator
    builder = SearchQueryBuilder.new('w:bleargh')
    refute_equal builder.parse_error, nil
  end

  def test_is_banned_no_restriction_specified
    input = %Q{is_banned:true}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_banned = ?', builder.where 
    assert_equal ['true'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_is_restricted_no_restriction_specified
    input = %Q{is_restricted:true}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_restricted = ?', builder.where 
    assert_equal ['true'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_is_banned_restriction_specified
    input = %Q{is_banned:true restriction_id:ban_list_foo}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_banned = ? AND lower(unified_restrictions.restriction_id) LIKE ?', builder.where 
    assert_equal ['true', '%ban_list_foo%'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_is_restricted_restriction_specified
    input = %Q{is_restricted:true restriction_id:ban_list_foo}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_restricted = ? AND lower(unified_restrictions.restriction_id) LIKE ?', builder.where 
    assert_equal ['true', '%ban_list_foo%'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_eternal_points
    input = %Q{eternal_points:3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.eternal_points = ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_global_penalty
    input = %Q{global_penalty:3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.global_penalty = ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_universal_faction_cost
    input = %Q{universal_faction_cost:3}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.universal_faction_cost = ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_card_pool
    input = %Q{card_pool:best_pool}
    builder = SearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(card_pools_cards.card_pool_id) LIKE ?', builder.where 
    assert_equal ['%best_pool%'], builder.where_values
    assert_equal [:card_pool_cards], builder.left_joins
  end

end