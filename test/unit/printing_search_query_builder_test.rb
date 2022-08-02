require 'minitest/autorun'
require 'parslet/convenience'

class PrintingSearchQueryBuilderTest < Minitest::Test
  def test_simple_successful_query
    input = %Q{x:trash}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_text) LIKE ?', builder.where 
    assert_equal ['%trash%'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_simple_successful_query_with_multiple_terms
    input = %Q{x:trash cost:3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_text) LIKE ? AND cards.cost = ?', builder.where 
    assert_equal ['%trash%', '3'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_numeric_field_not_equal 
    input = %Q{trash_cost!3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost != ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_numeric_field_less_than
    input = %Q{trash_cost<3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost < ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_numeric_field_less_than_equal_to
    input = %Q{trash_cost<=3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost <= ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_numeric_field_greater_than
    input = %Q{trash_cost>3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost > ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_numeric_field_greater_than_equal_to
    input = %Q{trash_cost>=3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'cards.trash_cost >= ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_string_field_not_like
    input = %Q{title!sure}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%sure%'], builder.where_values
    assert_equal [:card], builder.left_joins
  end

  def test_boolean_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each {|op|
      input = 'is_unique%strue' % op
      builder = PrintingSearchQueryBuilder.new(input)

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
      builder = PrintingSearchQueryBuilder.new(input)

      assert_equal 'Invalid string operator "%s"' % op, builder.parse_error
      assert_equal '', builder.where
      assert_equal [], builder.where_values
      assert_equal [], builder.left_joins
    }
  end

  def test_bare_word 
    input = %Q{diversion}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) LIKE ?', builder.where 
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bare_word_negated 
    input = %Q{!diversion}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_quoted_string_negated 
    input = %Q{"!diversion of funds"}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(cards.stripped_title) NOT LIKE ?', builder.where 
    assert_equal ['%diversion of funds%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_query_bad_operator
    builder = PrintingSearchQueryBuilder.new('w:bleargh')
    refute_equal builder.parse_error, nil
  end

  def test_is_banned_no_restriction_specified
    input = %Q{is_banned:true}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_banned = ?', builder.where 
    assert_equal ['true'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_is_restricted_no_restriction_specified
    input = %Q{is_restricted:true}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_restricted = ?', builder.where 
    assert_equal ['true'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_is_banned_restriction_specified
    input = %Q{is_banned:true restriction_id:ban_list_foo}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_banned = ? AND lower(unified_restrictions.restriction_id) LIKE ?', builder.where 
    assert_equal ['true', '%ban_list_foo%'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_is_restricted_restriction_specified
    input = %Q{is_restricted:true restriction_id:ban_list_foo}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.is_restricted = ? AND lower(unified_restrictions.restriction_id) LIKE ?', builder.where 
    assert_equal ['true', '%ban_list_foo%'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_eternal_points
    input = %Q{eternal_points:3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.eternal_points = ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_global_penalty
    input = %Q{global_penalty:3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.global_penalty = ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_universal_faction_cost
    input = %Q{universal_faction_cost:3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_restrictions.universal_faction_cost = ?', builder.where 
    assert_equal ['3'], builder.where_values
    assert_equal [:unified_restrictions], builder.left_joins
  end

  def test_card_pool
    input = %Q{card_pool:best_pool}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(card_pools_cards.card_pool_id) LIKE ?', builder.where 
    assert_equal ['%best_pool%'], builder.where_values
    assert_equal [:card_pool_cards], builder.left_joins
  end

  def test_bad_boolean_value
    input = %Q{is_banned:nah}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_equal 'Invalid value "nah" for boolean field "is_banned"', builder.parse_error
    assert_equal '', builder.where
    assert_equal [], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_numeric_value
    input = %Q{trash_cost:"too damn high"}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_equal 'Invalid value "too damn high" for integer field "trash_cost"', builder.parse_error
    assert_equal '', builder.where
    assert_equal [], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_release_date_full
    input = %Q{release_date:2022-07-22}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'printings.date_release = ?', builder.where
    assert_equal ['2022-07-22'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_release_date_short
    input = %Q{r>=20220722}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'printings.date_release >= ?', builder.where
    assert_equal ['20220722'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_date_value
    input = %Q{release_date:Jul-22-2022}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_equal 'Invalid value "jul-22-2022" for date field "release_date" - only YYYY-MM-DD or YYYYMMDD are supported.', builder.parse_error
    assert_equal '', builder.where
    assert_equal [], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_illustrator_full
    input = %Q{illustrator:Zeilinger}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(illustrators.name) LIKE ?', builder.where
    assert_equal ['%zeilinger%'], builder.where_values
    assert_equal [:illustrators], builder.left_joins
  end

  def test_illustrator_short
    input = %Q{i!Zeilinger}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(illustrators.name) NOT LIKE ?', builder.where
    assert_equal ['%zeilinger%'], builder.where_values
    assert_equal [:illustrators], builder.left_joins
  end

end
