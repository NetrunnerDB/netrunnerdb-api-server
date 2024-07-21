# frozen_string_literal: true

require 'minitest/autorun'
require 'parslet/convenience'

class CardSearchQueryBuilderTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  def test_simple_successful_query
    input = %(x:trash)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_cards.stripped_text) LIKE ?', builder.where
    assert_equal ['%trash%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_simple_successful_query_with_multiple_terms
    input = %(x:trash cost:3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_cards.stripped_text) LIKE ? AND unified_cards.cost = ?', builder.where
    assert_equal ['%trash%', '3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_not_equal
    input = %(trash_cost!3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_cards.trash_cost != ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_less_than
    input = %(trash_cost<3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_cards.trash_cost < ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_less_than_equal_to
    input = %(trash_cost<=3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_cards.trash_cost <= ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_greater_than
    input = %(trash_cost>3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_cards.trash_cost > ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_greater_than_equal_to
    input = %(trash_cost>=3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_cards.trash_cost >= ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_string_field_not_like
    input = %(title!sure)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_cards.stripped_title) NOT LIKE ?', builder.where
    assert_equal ['%sure%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_boolean_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each do |op|
      input = "is_unique#{op}true"
      begin
        CardSearchQueryBuilder.new(input)
        assert_not(true, 'parser unexpectedly passed')
      rescue RuntimeError => e
        assert_equal "Invalid boolean operator \"#{op}\"", e.message
      end
    end
  end

  def test_string_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each do |op|
      input = "title#{op}sure"
      begin
        CardSearchQueryBuilder.new(input)
        assert_not(true, 'parser unexpectedly passed')
      rescue RuntimeError => e
        assert_equal "Invalid string operator \"#{op}\"", e.message
      end
    end
  end

  def test_bare_word
    input = %(diversion)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_cards.stripped_title) LIKE ?', builder.where
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bare_word_negated
    input = %(!diversion)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'NOT lower(unified_cards.stripped_title) LIKE ?', builder.where
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_quoted_string_negated
    input = %(!"diversion of funds")
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'NOT lower(unified_cards.stripped_title) LIKE ?', builder.where
    assert_equal ['%diversion of funds%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_query_bad_operator
    input = %('asdfasdf')
    begin
      CardSearchQueryBuilder.new("#{input}:bleargh")
    rescue RuntimeError => e
      assert_equal "Unknown keyword \"#{input}\"", e.message
    end
  end

  def test_is_banned_no_restriction_specified
    input = %(is_banned:true)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_banned))', builder.where.strip
    assert_equal ['true'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_is_restricted_no_restriction_specified
    input = %(is_restricted:true)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_restricted))', builder.where.strip
    assert_equal ['true'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_has_global_penalty_no_restriction_specified
    input = %(has_global_penalty:true)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_global_penalty))', builder.where.strip
    assert_equal ['true'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_is_banned_restriction_specified
    input = %(is_banned:true restriction_id:ban_list_foo)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_banned)) AND  (? = ANY(unified_cards.restriction_ids))',
                 builder.where.strip
    assert_equal %w[true ban_list_foo], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_is_restricted_restriction_specified
    input = %(is_restricted:true restriction_id:ban_list_foo)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_restricted)) AND  (? = ANY(unified_cards.restriction_ids))',
                 builder.where.strip
    assert_equal %w[true ban_list_foo], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_has_global_penalty_restriction_specified
    input = %(has_global_penalty:true restriction_id:ban_list_foo)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_global_penalty)) AND  (? = ANY(unified_cards.restriction_ids))',
                 builder.where.strip
    assert_equal %w[true ban_list_foo], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_eternal_points
    input = %(eternal_points:eternal_restriction_id-3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_points))', builder.where.strip
    assert_equal ['eternal_restriction_id=3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_universal_faction_cost
    input = %(universal_faction_cost:3)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.restrictions_universal_faction_cost))', builder.where.strip
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_card_pool
    input = %(card_pool:best_pool)
    builder = CardSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_cards.card_pool_ids))', builder.where.strip
    assert_equal ['best_pool'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_boolean_value
    input = %(additional_cost:nah)
    begin
      CardSearchQueryBuilder.new(input)
    rescue RuntimeError => e
      assert_equal 'Invalid value "nah" for boolean field "additional_cost"', e.message
    end
  end

  def test_bad_numeric_value
    input = %(trash_cost:"too damn high")
    begin
      CardSearchQueryBuilder.new(input)
    rescue RuntimeError => e
      assert_equal 'Invalid value "too damn high" for integer field "trash_cost"', e.message
    end
  end
end
