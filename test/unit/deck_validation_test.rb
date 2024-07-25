# frozen_string_literal: true

class DeckValidationTest < ActiveSupport::TestCase
  def setup
    @empty_validation = {
      'label' => 'empty'
    }
    @snapshot_only = {
      'label' => 'expand snapshot',
      'snapshot_id' => 'standard_02'
    }
    @format_only = {
      'label' => 'expand format',
      'format_id' => 'standard'
    }
    @card_pool_only = {
      'label' => 'expand card_pool',
      'card_pool_id' => 'startup_02'
    }
    @restriction_only = {
      'label' => 'expand restriction',
      'restriction_id' => 'standard_banlist'
    }
  end

  def test_empty_validation
    v = DeckValidation.new(@empty_validation)

    assert_equal 'empty', v.label
    assert v.format_id.nil?
    assert v.card_pool_id.nil?
    assert v.restriction_id.nil?
    assert v.snapshot_id.nil?
    assert v.valid?
  end

  def test_expand_snapshot
    v = DeckValidation.new(@snapshot_only)

    assert_equal 'expand snapshot', v.label
    assert_equal 'standard', v.format_id
    assert_equal 'standard_02', v.card_pool_id
    assert_equal 'standard_banlist', v.restriction_id
    assert_equal 'standard_02', v.snapshot_id
    assert v.valid?
  end

  def test_expand_format
    v = DeckValidation.new(@format_only)

    assert_equal 'expand format', v.label
    assert_equal 'standard', v.format_id
    assert_equal 'standard_02', v.card_pool_id
    assert_equal 'standard_banlist', v.restriction_id
    assert_equal 'standard_02', v.snapshot_id
    assert v.valid?
  end

  def test_expand_card_pool
    v = DeckValidation.new(@card_pool_only)

    assert_equal 'expand card_pool', v.label
    assert_equal 'startup', v.format_id
    assert_equal 'startup_02', v.card_pool_id
    assert v.restriction_id.nil?
    assert v.snapshot_id.nil?
    assert v.valid?
  end

  def test_expand_restriction
    v = DeckValidation.new(@restriction_only)

    assert_equal 'expand restriction', v.label
    assert_equal 'standard', v.format_id
    assert_equal 'standard_banlist', v.restriction_id
    assert v.card_pool_id.nil?
    assert v.snapshot_id.nil?
    assert v.valid?
  end
end
