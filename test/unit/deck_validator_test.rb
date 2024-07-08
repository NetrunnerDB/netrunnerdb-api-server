require 'test_helper'

class DeckValidatorTest < ActiveSupport::TestCase
  def setup
    @empty_deck = {}

    # Using => format to ensure that all keys remain strings, like we get in the web app.
    @missing_identity = { 'side_id' => 'corp' }
    @missing_side = { 'identity_card_id' => ''}

    @invalid_with_multiple_validations = {
      'identity_card_id' => '',
      'validations' => [
        {
          "label" => "validation 1",
          "basic_deckbuilding_rules" => false,
        },
        {
          "label" => "validation 2",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }

    @imaginary_identity = {
      'identity_card_id' => 'plural',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          "label" => "Straight Up Basic Deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }
    @imaginary_side = {
      'identity_card_id' => 'armand_geist_walker_tech_lord',
      'side_id' => 'super_mega_corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          "label" => "straight up basic deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }

    @wrong_side_asa_group = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'runner',
      'validations' => [
        {
          "label" => "straight up basic deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }
    @wrong_side_geist = {
      'identity_card_id' => 'armand_geist_walker_tech_lord',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          "label" => "straight up basic deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }

    @bad_cards_asa_group = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => { 'foo' => 3, 'bar' => 3 },
      'validations' => [
        {
          "label" => "straight up basic deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
   }
    @too_few_cards_asa_group = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          "label" => "straight up basic deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
  }

    @not_enough_agenda_points_too_many_copies = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 36, 'project_vitruvius' => 9 },
      'validations' => [
        {
          "label" => "straight up basic deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }

    @too_much_influence_asa_group = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => {
        'ikawah_project' => 3,
        'project_vitruvius' => 3,
        'send_a_message' => 2,
        'regolith_mining_license' => 3,
        'spin_doctor' => 3,
        'trieste_model_bioroids' => 3,
        'biotic_labor' => 3,
        'hedge_fund' => 3,
        'punitive_counterstrike' => 3,
        'funhouse' => 3,
        'hagen' => 3,
        'hakarl_1_0' => 3,
        'enigma' => 3,
        'tollbooth' => 3,
        'ansel_1_0' => 3,
        'rototurret' => 3,
        'tyr' => 2,
      },
      'validations' => [
        {
          "label" => "straight up basic deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
     }

    @good_asa_group = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => {
        'ikawah_project' => 3,
        'project_vitruvius' => 3,
        'send_a_message' => 2,
        'regolith_mining_license' => 3,
        'spin_doctor' => 3,
        'trieste_model_bioroids' => 3,
        'biotic_labor' => 3,
        'hedge_fund' => 3,
        'punitive_counterstrike' => 3,
        'eli_1_0' => 3,
        'hagen' => 3,
        'hakarl_1_0' => 3,
        'enigma' => 3,
        'tollbooth' => 3,
        'ansel_1_0' => 3,
        'rototurret' => 3,
        'tyr' => 2,
      },
      'validations' => [
        {
          "label" => "Straight Up Basic Deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }
    @good_asa_without_basic_deckbuilding_validations = disable_basic_deckbuilding_rules_at_position(@good_asa_group, 0)
    @upper_case_asa_group = force_uppercase(@good_asa_group)
    @runner_econ_asa_group = swap_card(@good_asa_group, 'hedge_fund', 'sure_gamble')
    @out_of_faction_agenda = add_out_of_faction_agenda(@good_asa_group)

    @good_ampere = {
      'identity_card_id' => 'ampere_cybernetics_for_anyone',
      'side_id' => 'corp',
      'cards' => {
        'afshar' => 1,
        'aiki' => 1,
        'anoetic_void' => 1,
        'ansel_1_0' => 1,
        'argus_crackdown' => 1,
        'ark_lockdown' => 1,
        'artificial_cryptocrash' => 1,
        'audacity' => 1,
        'bathynomus' => 1,
        'bellona' => 1,
        'biotic_labor' => 1,
        'border_control' => 1,
        'celebrity_gift' => 1,
        'eli_1_0' => 1,
        'enigma' => 1,
        'envelopment' => 1,
        'fairchild_3_0' => 1,
        'formicary' => 1,
        'funhouse' => 1,
        'ganked' => 1,
        'hagen' => 1,
        'hakarl_1_0' => 1,
        'hansei_review' => 1,
        'hedge_fund' => 1,
        'hostile_takeover' => 1,
        'hybrid_release' => 1,
        'hydra' => 1,
        'ikawah_project' => 1,
        'jinja_city_grid' => 1,
        'lady_liberty' => 1,
        'longevity_serum' => 1,
        'luminal_transubstantiation' => 1,
        'punitive_counterstrike' => 1,
        'rashida_jaheem' => 1,
        'regolith_mining_license' => 1,
        'reversed_accounts' => 1,
        'ronin' => 1,
        'rototurret' => 1,
        'sds_drone_deployment' => 1,
        'send_a_message' => 1,
        'spin_doctor' => 1,
        'surveyor' => 1,
        'thimblerig' => 1,
        'tollbooth' => 1,
        'trieste_model_bioroids' => 1,
        'tyr' => 1,
        'urban_renewal' => 1,
        'urtica_cipher' => 1,
        'wraparound' => 1,
      },
      'validations' => [
        {
          "label" => "Straight Up Basic Deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]

    }

    @ampere_with_too_many_cards = set_card_quantity(set_card_quantity(@good_ampere, 'tyr', 2), 'hedge_fund', 2)
    @ampere_too_many_agendas_from_one_faction = swap_card(@good_ampere, 'hostile_takeover', 'ar_enhanced_security')

    @good_nova = {
      'identity_card_id' => 'nova_initiumia_catalyst_impetus',
      'side_id' => 'runner',
      'cards' => {
        'beth_kilrain_chang' => 1,
        'boomerang' => 1,
        'botulus' => 1,
        'bravado' => 1,
        'build_script' => 1,
        'bukhgalter' => 1,
        'career_fair' => 1,
        'cezve' => 1,
        'creative_commission' => 1,
        'daily_casts' => 1,
        'deuces_wild' => 1,
        'diesel' => 1,
        'dirty_laundry' => 1,
        'diversion_of_funds' => 1,
        'dr_nuka_vrolyck' => 1,
        'dreamnet' => 1,
        'earthrise_hotel' => 1,
        'emergent_creativity' => 1,
        'endurance' => 1,
        'falsified_credentials' => 1,
        'fermenter' => 1,
        'find_the_truth' => 1,
        'labor_rights' => 1,
        'liberated_account' => 1,
        'logic_bomb' => 1,
        'mad_dash' => 1,
        'miss_bones' => 1,
        'neutralize_all_threats' => 1,
        'no_free_lunch' => 1,
        'overclock' => 1,
        'paladin_poemu' => 1,
        'paperclip' => 1,
        'pinhole_threading' => 1,
        'simulchip' => 1,
        'stargate' => 1,
        'steelskin_scarring' => 1,
        'sure_gamble' => 1,
        'telework_contract' => 1,
        'the_class_act' => 1,
        'unity' => 1,
      },
      'validations' => [
        {
          "label" => "Straight Up Basic Deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }

    @good_ken = {
      'identity_card_id' => 'ken_express_tenma_disappeared_clone',
      'side_id' => 'runner',
      'cards' => {
        'bravado' => 3,
        'carpe_diem' => 3,
        'dirty_laundry' => 3,
        'embezzle' => 2,
        'inside_job' => 2,
        'legwork' => 1,
        'marathon' => 2,
        'mutual_favor' => 2,
        'networking' => 1,
        'sure_gamble' => 3,
        'boomerang' => 2,
        'buffer_drive' => 1,
        'ghosttongue' => 1,
        'pennyshaver' => 2,
        'wake_implant_v2a_jrj' => 1,
        'aeneas_informant' => 3,
        'daily_casts' => 3,
        'dreamnet' => 1,
        'the_class_act' => 2,
        'aumakua' => 1,
        'bukhgalter' => 1,
        'cats_cradle' => 1,
        'paperclip' => 1,
        'bankroll' => 3,
      },
      'validations' => [
        {
          "label" => "Straight Up Basic Deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }
    @corp_econ_ken = swap_card(@good_ken, 'sure_gamble', 'hedge_fund')
    @bad_ken_without_basic_deckbuilding_rules = disable_basic_deckbuilding_rules_at_position(@corp_econ_ken, 0)
    @nova_with_too_many_cards = set_card_quantity(set_card_quantity(@good_nova, 'sure_gamble', 2), 'unity', 2)

    @good_professor = {
      'identity_card_id' => 'the_professor_keeper_of_knowledge',
      'side_id' => 'runner',
      'cards' => {
        'aumakua' => 1,
        'bankroll' => 1,
        'botulus' => 1,
        'bukhgalter' => 1,
        'cezve' => 1,
        'clot' => 1,
        'compile' => 2,
        'consume' => 1,
        'creative_commission' => 3,
        'cybertrooper_talut' => 2,
        'dirty_laundry' => 3,
        'dzmz_optimizer' => 2,
        'fermenter' => 1,
        'jailbreak' => 3,
        'leech' => 2,
        'mad_dash' => 2,
        'overclock' => 3,
        'prepaid_voicepad' => 2,
        'professional_contacts' => 2,
        'spec_work' => 2,
        'stargate' => 1,
        'sure_gamble' => 3,
        'tapwrm' => 1,
        'the_makers_eye' => 2,
        'top_hat' => 2,
      },
      'validations' => [
        {
          "label" => "Straight Up Basic Deckbuilding rules and nothing else.",
          "basic_deckbuilding_rules" => true,
        }
      ]
    }
    @too_much_program_influence_professor = set_card_quantity(set_card_quantity(@good_professor, 'consume', 2), 'stargate', 2)
  end

  def force_uppercase(deck)
    new_deck = deck.deep_dup
    new_deck['identity_card_id'].upcase!
    new_deck['side_id'].upcase!
    new_deck.deep_transform_keys!(&:upcase)
    return new_deck
  end

  def disable_basic_deckbuilding_rules_at_position(deck, position)
    new_deck = deck.deep_dup
    new_deck['validations'][position]['basic_deckbuilding_rules'] = false
    return new_deck
  end

  def swap_identity(deck, identity)
    new_deck = deck.deep_dup
    new_deck['identity_card_id'] = identity
    return new_deck
  end

  def swap_card(deck, old_card_id, new_card_id)
    new_deck = deck.deep_dup
    new_deck['cards'][new_card_id] = new_deck['cards'][old_card_id]
    new_deck['cards'].delete(old_card_id)
    return new_deck
  end

  def set_card_quantity(deck, card_id, quantity)
    new_deck = deck.deep_dup
    new_deck['cards'][card_id] = quantity
    return new_deck
  end

  def add_out_of_faction_agenda(deck)
    new_deck = deck.deep_dup
    new_deck['cards'].delete('send_a_message')
    new_deck['cards']['bellona'] = deck['cards']['send_a_message']
    return new_deck
  end

  def test_validation_without_basic_deckbuilding_rules
    v = DeckValidator.new(@good_asa_without_basic_deckbuilding_validations)
    assert v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @good_asa_without_basic_deckbuilding_validations['validations'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_validation_without_basic_deckbuilding_rules
    v = DeckValidator.new(@bad_ken_without_basic_deckbuilding_rules)
    assert v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @bad_ken_without_basic_deckbuilding_rules['validations'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_good_corp_side
    v = DeckValidator.new(@good_asa_group)
    assert v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @good_asa_group['validations'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_good_ampere
    v = DeckValidator.new(@good_ampere)
    assert v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @good_ampere['validations'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_good_runner_side
    v = DeckValidator.new(@good_ken)
    assert v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @good_ken['validations'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_good_nova
    v = DeckValidator.new(@good_nova)
    assert v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @good_nova['validations'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_good_professor
    v = DeckValidator.new(@good_professor)
    assert v.is_valid?

    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @good_professor['validations'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_is_valid_is_idempotent
    # Errors won't keep accumulating if is_valid? is called repeatedly.
    v = DeckValidator.new(@too_much_program_influence_professor)
    [0, 1, 2, 3, 4, 5].each do |i|
      assert !v.is_valid?
      assert_equal 0, v.errors.size
      assert_equal v.validations.size, @too_much_program_influence_professor['validations'].size
      assert_equal 1, v.validations[0].errors.size
    end
  end

  def test_corp_identities_are_not_valid_cards_for_basic_deckbuilding
    deck = swap_card(@good_ampere.deep_dup, 'ark_lockdown', 'asa_group_security_through_vigilance')

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, deck['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, 'Decks may not include multiple identities.  Identity card `asa_group_security_through_vigilance` is not allowed.'
  end

  def test_runner_identities_are_not_valid_cards_for_basic_deckbuilding
    deck = @good_nova.deep_dup
    deck['cards']['armand_geist_walker_tech_lord'] = 3

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, deck['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, 'Decks may not include multiple identities.  Identity card `armand_geist_walker_tech_lord` is not allowed.'
  end

  def test_too_much_program_influence_professor
    v = DeckValidator.new(@too_much_program_influence_professor)
    assert !v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @too_much_program_influence_professor['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, "Influence limit for The Professor: Keeper of Knowledge is 1, but deck has spent 9 influence"
  end

  def test_case_normalization
    v = DeckValidator.new(@upper_case_asa_group)
    assert v.is_valid?
    assert_equal 0, v.errors.size
    assert_equal v.validations.size, @upper_case_asa_group['VALIDATIONS'].size
    assert v.validations[0].is_valid?
    assert_equal 0, v.validations[0].errors.size
  end

  def test_empty_deck_json
    v = DeckValidator.new(@empty_deck)
    assert !v.is_valid?, 'Empty Deck JSON fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
    assert_includes v.errors, "Deck is missing `side_id` field."
    assert_includes v.errors, "Deck must specify some cards."
    assert_includes v.errors, "Validation request must specify at least one validation to perform."
  end

  def test_missing_identity
    v = DeckValidator.new(@missing_identity)
    assert !v.is_valid?, 'Deck JSON missing identity fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
  end

  def test_missing_side
    v = DeckValidator.new(@missing_side)
    assert !v.is_valid?, 'Deck JSON missing side fails validation'
    assert_includes v.errors, "Deck is missing `side_id` field."
  end

  def test_imaginary_identity
    v = DeckValidator.new(@imaginary_identity)
    assert !v.is_valid?, 'Deck JSON has non-existent Identity'
    assert_includes v.errors, "`identity_card_id` `plural` does not exist."
  end

  def test_imaginary_side
    v = DeckValidator.new(@imaginary_side)
    assert !v.is_valid?, 'Deck JSON has non-existent side'
    assert_includes v.errors, "`side_id` `super_mega_corp` does not exist."
  end

  def test_corp_deck_with_runner_card
    v = DeckValidator.new(@runner_econ_asa_group)
    assert !v.is_valid?
    assert_equal v.validations.size, @runner_econ_asa_group['validations'].size
    assert !v.validations[0].is_valid?, "Basic deckbuilding validation fails."
    assert_includes v.validations[0].errors, "Card `sure_gamble` side `runner` does not match deck side `corp`"
  end

  def test_out_of_faction_agendas
    v = DeckValidator.new(@out_of_faction_agenda)
    assert !v.is_valid?
    assert_equal v.validations.size, @out_of_faction_agenda['validations'].size
    assert !v.validations[0].is_valid?, "Basic deckbuilding validation fails."
    assert_includes v.validations[0].errors, "Agenda `bellona` with faction_id `nbn` is not allowed in a `haas_bioroid` deck."
  end

  def test_out_of_faction_agendas_ampere
    v = DeckValidator.new(@ampere_too_many_agendas_from_one_faction)
    assert !v.is_valid?
    assert_equal v.validations.size, @ampere_too_many_agendas_from_one_faction['validations'].size
    assert !v.validations[0].is_valid?, "Basic deckbuilding validation fails."
    assert_includes v.validations[0].errors, "Ampere decks may not include more than 2 agendas per non-neutral faction. There are 3 `nbn` agendas present."
  end

  def test_mismatched_side_corp_id
    v = DeckValidator.new(@corp_econ_ken)
    assert !v.is_valid?
    assert_equal v.validations.size, @corp_econ_ken['validations'].size
    assert !v.validations[0].is_valid?, 'Runner deck with corp card fails.'
    assert_includes v.validations[0].errors, "Card `hedge_fund` side `corp` does not match deck side `runner`"
  end

  def test_mismatched_side_runner_id
    v = DeckValidator.new(@wrong_side_geist)
    assert !v.is_valid?
    assert_equal v.validations.size, @wrong_side_geist['validations'].size
    assert !v.validations[0].is_valid?, 'Deck with mismatched id and specified side fails'
    assert_includes v.validations[0].errors, "Identity `armand_geist_walker_tech_lord` has side `runner` which does not match given side `corp`"
  end

  def test_not_enough_agenda_points
    v = DeckValidator.new(@not_enough_agenda_points_too_many_copies)
    assert !v.is_valid?
    assert_equal v.validations.size, @not_enough_agenda_points_too_many_copies['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, "Deck with size 45 requires [20,21] agenda points, but deck only has 18"
  end

  def test_too_many_copies
    v = DeckValidator.new(@not_enough_agenda_points_too_many_copies)
    assert !v.is_valid?
    assert_equal v.validations.size, @not_enough_agenda_points_too_many_copies['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, 'Card `hedge_fund` has a deck limit of 3, but 36 copies are included.'
    assert_includes v.validations[0].errors, 'Card `project_vitruvius` has a deck limit of 3, but 9 copies are included.'
  end

  def test_too_many_copies_ampere
    v = DeckValidator.new(@ampere_with_too_many_cards)
    assert !v.is_valid?
    assert_equal v.validations.size, @ampere_with_too_many_cards['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, "Card `hedge_fund` has a deck limit of 1, but 2 copies are included."
    assert_includes v.validations[0].errors, "Card `tyr` has a deck limit of 1, but 2 copies are included."
  end

  def test_too_may_copies_nova
    v = DeckValidator.new(@nova_with_too_many_cards)
    assert !v.is_valid?
    assert_equal v.validations.size, @nova_with_too_many_cards['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, "Card `sure_gamble` has a deck limit of 1, but 2 copies are included."
    assert_includes v.validations[0].errors, "Card `unity` has a deck limit of 1, but 2 copies are included."
  end

  def test_corp_too_much_influence
    v = DeckValidator.new(@too_much_influence_asa_group)
    assert !v.is_valid?
    assert_equal v.validations.size, @too_much_influence_asa_group['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, "Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence"
  end

  def test_bad_cards
    v = DeckValidator.new(@bad_cards_asa_group)
    assert !v.is_valid?
    assert_equal v.validations.size, @bad_cards_asa_group['validations'].size
    assert_includes v.errors, "Card `foo` does not exist."
    assert_includes v.errors, "Card `bar` does not exist."
  end

  def test_deck_with_missing_validations_has_no_validations
    v = DeckValidator.new(@empty_deck)
    assert_equal 0, v.validations.size
  end

  def test_initializes_validations_properly
    v = DeckValidator.new(@invalid_with_multiple_validations)
    assert_equal 2, v.validations.size

    assert_equal 'validation 1', v.validations[0].label
    assert !v.validations[0].basic_deckbuilding_rules
    assert_equal 'validation 2', v.validations[1].label
    assert v.validations[1].basic_deckbuilding_rules
  end

  def test_too_few_cards
    v = DeckValidator.new(@too_few_cards_asa_group)
    assert !v.is_valid?
    assert_equal v.validations.size, @too_few_cards_asa_group['validations'].size
    assert !v.validations[0].is_valid?
    assert_includes v.validations[0].errors, "Minimum deck size is 45, but deck has 3 cards."
  end

 def test_invalid_format_id
   deck = @good_asa_group.deep_dup
   deck['validations'][0]['format_id'] = 'magic_the_gathering'
   v = DeckValidator.new(deck)
   assert !v.is_valid?
   assert_equal v.validations.size, deck['validations'].size
   # TODO: Update validation to explicitly set is_valid? to false and have the validator set it to true as a literal iff valid.
   # assert v.validations[0].is_valid?
   assert_includes v.errors, "Format `magic_the_gathering` does not exist."
 end

  def test_invalid_card_pool_id
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['card_pool_id'] = 'startup_2099'
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.errors, "Card Pool `startup_2099` does not exist."
  end

  def test_invalid_restriction_id
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['restriction_id'] = 'standard_banlist_2034_03'
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.errors, "Restriction `standard_banlist_2034_03` does not exist."
  end

  def test_invalid_snapshot_id
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['snapshot_id'] = 'snapshot_3030'
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.errors, "Snapshot `snapshot_3030` does not exist."
  end

  def test_cards_not_in_specified_card_pool
    deck = @good_asa_group.deep_dup
    # Test fixture standard_02 is not a full representation of standard.
    deck['validations'][0]['card_pool_id'] = 'standard_02'
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    # Ensure all invalid cards are reported as errors.
    [
      'ansel_1_0',
      'biotic_labor',
      'eli_1_0',
      'enigma',
      'hagen',
      'hakarl_1_0',
      'ikawah_project',
      'project_vitruvius',
      'regolith_mining_license',
      'rototurret',
      'spin_doctor',
      'tollbooth',
    ].each do |c|
      assert_includes v.validations[0].errors, "Card `%s` is not present in Card Pool `standard_02`." % c
    end
  end

  def test_banned_card
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['format_id'] = 'standard'
    deck['validations'][0].delete('card_pool_id')
    deck['validations'][0].delete('restriction_id')
    deck['validations'][0].delete('snapshot_id')

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    puts v.validations[0].inspect
    assert_includes v.validations[0].errors, 'Card `trieste_model_bioroids` is banned in restriction `standard_banlist`.'
  end

  def test_too_many_restricted_cards
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['restriction_id'] = 'standard_restricted'
    deck['validations'][0].delete('card_pool_id')
    deck['validations'][0].delete('format_id')
    deck['validations'][0].delete('snapshot_id')

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Deck has too many cards marked restricted in restriction `standard_restricted`: send_a_message, trieste_model_bioroids.'
  end

  def test_global_penalty_reduces_influence
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['restriction_id'] = 'standard_global_penalty'
    deck['validations'][0].delete('format_id')
    deck['validations'][0].delete('card_pool_id')
    deck['validations'][0].delete('snapshot_id')

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Influence limit for Asa Group: Security Through Vigilance is 13 after Global Penalty applied from restriction `standard_global_penalty`, but deck has spent 2 influence from tyr (2).'
  end

  def test_universal_influence
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['restriction_id'] = 'standard_universal_faction_cost'
    deck['validations'][0].delete('format_id')
    deck['validations'][0].delete('card_pool_id')
    deck['validations'][0].delete('snapshot_id')

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Influence limit for Asa Group: Security Through Vigilance is 15, but after Universal Influence applied from restriction `standard_universal_faction_cost`, deck has spent 24 influence from punitive_counterstrike (9).'
  end

  def test_over_eternal_points_limit
    deck = @good_asa_group.deep_dup
    deck['validations'][0]['snapshot_id'] = 'eternal_01'
    deck['validations'][0].delete('card_pool_id')
    deck['validations'][0].delete('format_id')
    deck['validations'][0].delete('restriction_id')

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Deck has too many points (9) for eternal restriction `eternal_points_list`: send_a_message (3), punitive_counterstrike (3), tyr (3).'
  end

  # Mumba Temple costs 0 instead of 2 influence if the deck has >= 15 ice
  def test_mumba_temple
    #
    #    'eli_1_0' => 3,
    #    'hagen' => 3,
    #    'hakarl_1_0' => 3,
    #    'enigma' => 3,
    #    'tollbooth' => 3,
    #    'ansel_1_0' => 3,
    #    'rototurret' => 3,
    #    'tyr' => 2,
    # Cut 9 pieces of ice
     # Swap 3 cards for Museum of History, deck under 50 should fail.
    deck = swap_card(swap_card(swap_card(@good_asa_group.deep_dup, 'hagen', 'mumba_temple'), 'hakarl_1_0', 'ark_lockdown'), 'ansel_1_0', 'prisec')
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'

    deck = swap_card(@good_asa_group.deep_dup, 'hagen', 'mumba_temple')
    v = DeckValidator.new(deck)
    assert v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
  end

  # Mumbad Virtual Tour costs 0 instead of 2 influence if the deck has >= 7 assets
  def test_mumbad_virtual_tour
    # Swap 3 cards for Museum of History, deck under 50 should fail.
    deck = swap_card(swap_card(@good_asa_group.deep_dup, 'hagen', 'mumbad_virtual_tour'), 'trieste_model_bioroids', 'ark_lockdown')
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'

    deck = swap_card(@good_asa_group.deep_dup, 'hagen', 'mumbad_virtual_tour')
    v = DeckValidator.new(deck)
    assert v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
  end

  # Museum costs 0 instead of 2 influence if the deck has >= 50 cards
  def test_museum_of_history
    # Swap 3 cards for Museum of History, deck under 50 should fail.
    deck = swap_card(@good_asa_group.deep_dup, 'hagen', 'museum_of_history')
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'

    deck = @good_asa_group.deep_dup
    deck['cards']['ontological_dependence'] = 1
    deck['cards']['museum_of_history'] = 3
    v = DeckValidator.new(deck)
    assert v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
  end

  # Pad factory costs 0 instead of 2 influence if the deck has 3 pad campaigns.
  def test_pad_factory
    # swap 3 cards for a pad factory, no pad campaigns, should add 6 influence.
    deck = swap_card(@good_asa_group.deep_dup, 'hagen', 'pad_factory')
    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, 'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'

    # swap 3 cards for pad factory, add 3 pad campaigns, influence should be fine.
    deck = swap_card(swap_card(@good_asa_group.deep_dup, 'hagen', 'pad_factory'), 'hakarl_1_0', 'pad_campaign')
    v = DeckValidator.new(deck)
    assert v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
  end

  def test_alliance_faction_locked
    deck = swap_card(swap_card(@good_asa_group, 'tollbooth', 'afshar'), 'tyr', 'consulting_visit')
    deck['cards']['afshar'] = 2
    deck['cards']['consulting_visit'] = 3
    deck['cards'].delete('rototurret')

    v = DeckValidator.new(deck)
    assert !v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
    assert_includes v.validations[0].errors, "Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 22 influence"

    # With 3 Afshar and 3 Punitive Counterstrike, there are 6 non-Alliance Weyland cards in the deck.
    deck['cards']['afshar'] = 3
    v = DeckValidator.new(deck)
    assert v.is_valid?
    assert_equal v.validations.size, deck['validations'].size
  end
end
