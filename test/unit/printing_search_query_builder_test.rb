require 'minitest/autorun'
require 'parslet/convenience'

class PrintingSearchQueryBuilderTest < Minitest::Test
  def test_simple_successful_query
    input = %Q{x:trash}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_printings.stripped_text) LIKE ?', builder.where
    assert_equal ['%trash%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_simple_successful_query_with_multiple_terms
    input = %Q{x:trash cost:3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_printings.stripped_text) LIKE ? AND unified_printings.cost = ?', builder.where
    assert_equal ['%trash%', '3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_not_equal
    input = %Q{trash_cost!3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_printings.trash_cost != ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_less_than
    input = %Q{trash_cost<3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_printings.trash_cost < ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_less_than_equal_to
    input = %Q{trash_cost<=3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_printings.trash_cost <= ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_greater_than
    input = %Q{trash_cost>3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_printings.trash_cost > ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_numeric_field_greater_than_equal_to
    input = %Q{trash_cost>=3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_printings.trash_cost >= ?', builder.where
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_string_field_not_like
    input = %Q{title!sure}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_printings.stripped_title) NOT LIKE ?', builder.where
    assert_equal ['%sure%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_boolean_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each {|op|
      input = 'is_unique%strue' % op
      begin
        builder = PrintingSearchQueryBuilder.new(input)
        refute(true, 'parser unexpectedly passed')
      rescue RuntimeError => e
        assert_equal 'Invalid boolean operator "%s"' % op, e.message
      end
    }
  end

  def test_string_field_bad_operators
    bad_operators = ['<', '<=', '>', '>=']
    bad_operators.each {|op|
      input = 'title%ssure' % op
      begin
        builder = PrintingSearchQueryBuilder.new(input)
        refute(true, 'parser unexpectedly passed')
      rescue RuntimeError => e
        assert_equal 'Invalid string operator "%s"' % op, e.message
      end
    }
  end

  def test_bare_word
    input = %Q{diversion}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_printings.stripped_title) LIKE ?', builder.where
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bare_word_negated
    input = %Q{!diversion}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'NOT lower(unified_printings.stripped_title) LIKE ?', builder.where
    assert_equal ['%diversion%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_quoted_string_negated
    input = %Q{!"diversion of funds"}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'NOT lower(unified_printings.stripped_title) LIKE ?', builder.where
    assert_equal ['%diversion of funds%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_query_bad_operator
    input = %Q{'asdfasdf'}
    begin
      builder = PrintingSearchQueryBuilder.new(input + ':bleargh')
    rescue RuntimeError => e
      assert_equal 'Unknown keyword "%s"' % input, e.message
    end
  end

  def test_is_banned_no_restriction_specified
    input = %Q{is_banned:true}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_banned))', builder.where.strip
    assert_equal ['true'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_is_restricted_no_restriction_specified
    input = %Q{is_restricted:true}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_restricted))', builder.where.strip
    assert_equal ['true'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_has_global_penalty_no_restriction_specified
    input = %Q{has_global_penalty:true}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_global_penalty))', builder.where.strip
    assert_equal ['true'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_is_banned_restriction_specified
    input = %Q{is_banned:true restriction_id:ban_list_foo}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_banned)) AND  (? = ANY(unified_printings.restriction_ids))', builder.where.strip
    assert_equal ['true', 'ban_list_foo'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_is_restricted_restriction_specified
    input = %Q{is_restricted:true restriction_id:ban_list_foo}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_restricted)) AND  (? = ANY(unified_printings.restriction_ids))', builder.where.strip
    assert_equal ['true', 'ban_list_foo'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_has_global_penalty_restriction_specified
    input = %Q{has_global_penalty:true restriction_id:ban_list_foo}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_global_penalty)) AND  (? = ANY(unified_printings.restriction_ids))', builder.where.strip
    assert_equal ['true', 'ban_list_foo'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_eternal_points
    input = %Q{eternal_points:eternal_restriction_id-3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_points))', builder.where.strip
    assert_equal ['eternal_restriction_id=3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_universal_faction_cost
    input = %Q{universal_faction_cost:3}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.restrictions_universal_faction_cost))', builder.where.strip
    assert_equal ['3'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_card_pool
    input = %Q{card_pool:best_pool}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal '(? = ANY(unified_printings.card_pool_ids))', builder.where.strip
    assert_equal ['best_pool'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_boolean_value
    input = %Q{additional_cost:nah}
    begin
      builder = PrintingSearchQueryBuilder.new(input)
    rescue RuntimeError => e
      assert_equal 'Invalid value "nah" for boolean field "additional_cost"', e.message
    end
  end

  def test_bad_numeric_value
    input = %Q{trash_cost:"too damn high"}
    begin
      builder = PrintingSearchQueryBuilder.new(input)
    rescue RuntimeError => e
      assert_equal 'Invalid value "too damn high" for integer field "trash_cost"', e.message
    end
  end

  def test_release_date_full
    input = %Q{release_date:2022-07-22}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_printings.date_release = ?', builder.where
    assert_equal ['2022-07-22'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_release_date_short
    input = %Q{r>=20220722}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'unified_printings.date_release >= ?', builder.where
    assert_equal ['20220722'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_bad_date_value
    input = %Q{release_date:Jul-22-2022}
    begin
      builder = PrintingSearchQueryBuilder.new(input)
    rescue RuntimeError => e
      assert_equal 'Invalid value "jul-22-2022" for date field "release_date" - only YYYY-MM-DD or YYYYMMDD are supported.', e.message
    end
  end

  def test_illustrator_full
    input = %Q{illustrator:Zeilinger}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_printings.display_illustrators) LIKE ?', builder.where
    assert_equal ['%zeilinger%'], builder.where_values
    assert_equal [], builder.left_joins
  end

  def test_illustrator_short
    input = %Q{i!Zeilinger}
    builder = PrintingSearchQueryBuilder.new(input)

    assert_nil builder.parse_error
    assert_equal 'lower(unified_printings.display_illustrators) NOT LIKE ?', builder.where
    assert_equal ['%zeilinger%'], builder.where_values
    assert_equal [], builder.left_joins
  end

end
