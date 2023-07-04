class DeckValidatorTest < ActiveSupport::TestCase
  def setup
    @empty_deck = {}

    @missing_identity = { side_id: 'corp' }
    @missing_side = { identity_card_id: ''}

    @imaginary_identity = { identity_card_id: 'plural', side_id: 'corp' }
    @imaginary_side = { identity_card_id: 'geist', side_id: 'super_mega_corp' }

    @minimal_asa_group = { identity_card_id: 'asa_group', side_id: 'corp', cards: { 'hedge_fund': 3} }
    @minimal_geist = { identity_card_id: 'geist', side_id: 'runner', cards: { 'sure_gamble': 3} }

    @wrong_side_asa_group = { identity_card_id: 'asa_group', side_id: 'runner' }
    @wrong_side_geist = { identity_card_id: 'geist', side_id: 'corp' }
  end

  def test_empty_deck_json
    v = DeckValidator.new()
    assert !v.validate(@empty_deck), 'Empty Deck JSON fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
    assert_includes v.errors, "Deck is missing `side_id` field."
  end

  def test_missing_identity
    v = DeckValidator.new()
    assert !v.validate(@missing_identity), 'Deck JSON missing identity fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
  end

#  def test_missing_side
#    v = DeckValidator.new()
#    assert !v.validate(@missing_side), 'Deck JSON missing side fails validation'
#    assert_includes v.errors, "Deck is missing `side_id` field."
#  end
#
#  def test_imaginary_identity
#    v = DeckValidator.new()
#    assert !v.validate(@imaginary_identity), 'Deck JSON has non-existent Identity'
#    assert_includes v.errors, "`identity_card_id` `plural` does not exist."
#  end
#
#  def test_imaginary_side
#    v = DeckValidator.new()
#    assert !v.validate(@imaginary_side), 'Deck JSON has non-existent side'
#    assert_includes v.errors, "`side_id` `super_mega_corp` does not exist."
#  end
#
#  def test_mismatched_side_corp_id
#    v = DeckValidator.new()
#    assert !v.validate(@wrong_side_asa_group), 'Deck with mismatched id and specified side fails'
#    assert_equal 1, v.errors.size
#    assert_includes v.errors, "Identity `asa_group` has side `corp` which does not match given side `runner`"
#  end

  def test_mismatched_side_runner_id
    v = DeckValidator.new()
    assert !v.validate(@wrong_side_geist), 'Deck with mismatched id and specified side fails'
    assert_includes v.errors, "Identity `geist` has side `runner` which does not match given side `corp`"
  end

  def test_minimal_corp_side
    v = DeckValidator.new()
    assert v.validate(@minimal_asa_group)
    assert_equal 0, v.errors.size
  end

  def test_minimal_runner_side
    v = DeckValidator.new()
    assert v.validate(@minimal_asa_group)
    assert_equal 0, v.errors.size
  end
end
