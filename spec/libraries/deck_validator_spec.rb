# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeckValidator do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:empty_deck) { {} }

  # Using => format to ensure that all keys remain strings, like we get in the web app.
  let(:missing_identity) { { 'side_id' => 'corp' } }
  let(:missing_side) { { 'identity_card_id' => '' } }

  let(:invalid_with_multiple_validations) do
    {
      'identity_card_id' => '',
      'validations' => [
        {
          'label' => 'validation 1',
          'basic_deckbuilding_rules' => false
        },
        {
          'label' => 'validation 2',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:imaginary_identity) do
    {
      'identity_card_id' => 'plural',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          'label' => 'Straight Up Basic Deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:imaginary_side) do
    {
      'identity_card_id' => 'armand_geist_walker_tech_lord',
      'side_id' => 'super_mega_corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          'label' => 'straight up basic deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:wrong_side_asa_group) do
    {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'runner',
      'validations' => [
        {
          'label' => 'straight up basic deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:wrong_side_geist) do
    {
      'identity_card_id' => 'armand_geist_walker_tech_lord',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          'label' => 'straight up basic deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:bad_cards_asa_group) do
    {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => { 'foo' => 3, 'bar' => 3 },
      'validations' => [
        {
          'label' => 'straight up basic deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:too_few_cards_asa_group) do
    {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 3 },
      'validations' => [
        {
          'label' => 'straight up basic deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:not_enough_agenda_points_too_many_copies) do
    {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => { 'hedge_fund' => 36, 'project_vitruvius' => 9 },
      'validations' => [
        {
          'label' => 'straight up basic deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:too_much_influence_asa_group) do
    {
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
        'tyr' => 2
      },
      'validations' => [
        {
          'label' => 'straight up basic deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:good_asa_group) do
    {
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
        'tyr' => 2
      },
      'validations' => [
        {
          'label' => 'Straight Up Basic Deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:good_asa_without_basic_deckbuilding_validations) do
    disable_basic_deckbuilding_rules_at_position(good_asa_group, 0)
  end
  let(:upper_case_asa_group) { force_uppercase(good_asa_group) }
  let(:runner_econ_asa_group) { swap_card(good_asa_group, 'hedge_fund', 'sure_gamble') }
  let(:out_of_faction_agenda) { add_out_of_faction_agenda(good_asa_group) }

  let(:good_ampere) do
    {
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
        'wraparound' => 1
      },
      'validations' => [
        {
          'label' => 'Straight Up Basic Deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:ampere_with_too_many_cards) { set_card_quantity(set_card_quantity(good_ampere, 'tyr', 2), 'hedge_fund', 2) }
  let(:ampere_too_many_agendas_from_one_faction) { swap_card(good_ampere, 'hostile_takeover', 'ar_enhanced_security') }

  let(:good_nova) do
    {
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
        'unity' => 1
      },
      'validations' => [
        {
          'label' => 'Straight Up Basic Deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:good_ken) do
    {
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
        'bankroll' => 3
      },
      'validations' => [
        {
          'label' => 'Straight Up Basic Deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:corp_econ_ken) { swap_card(good_ken, 'sure_gamble', 'hedge_fund') }
  let(:bad_ken_without_basic_deckbuilding_rules) { disable_basic_deckbuilding_rules_at_position(corp_econ_ken, 0) }
  let(:nova_with_too_many_cards) { set_card_quantity(set_card_quantity(good_nova, 'sure_gamble', 2), 'unity', 2) }

  let(:good_professor) do
    {
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
        'top_hat' => 2
      },
      'validations' => [
        {
          'label' => 'Straight Up Basic Deckbuilding rules and nothing else.',
          'basic_deckbuilding_rules' => true
        }
      ]
    }
  end

  let(:too_much_program_influence_professor) do
    set_card_quantity(set_card_quantity(good_professor, 'consume', 2), 'stargate', 2)
  end

  def force_uppercase(deck)
    new_deck = deck.deep_dup
    new_deck['identity_card_id'].upcase!
    new_deck['side_id'].upcase!
    new_deck.deep_transform_keys!(&:upcase)
    new_deck
  end

  def disable_basic_deckbuilding_rules_at_position(deck, position)
    new_deck = deck.deep_dup
    new_deck['validations'][position]['basic_deckbuilding_rules'] = false
    new_deck
  end

  def swap_identity(deck, identity)
    new_deck = deck.deep_dup
    new_deck['identity_card_id'] = identity
    new_deck
  end

  def swap_card(deck, old_card_id, new_card_id)
    new_deck = deck.deep_dup
    new_deck['cards'][new_card_id] = new_deck['cards'][old_card_id]
    new_deck['cards'].delete(old_card_id)
    new_deck
  end

  def set_card_quantity(deck, card_id, quantity)
    new_deck = deck.deep_dup
    new_deck['cards'][card_id] = quantity
    new_deck
  end

  def add_out_of_faction_agenda(deck)
    new_deck = deck.deep_dup
    new_deck['cards'].delete('send_a_message')
    new_deck['cards']['bellona'] = deck['cards']['send_a_message']
    new_deck
  end

  it 'has no validations for a deck with missing validations' do
    v = described_class.new(empty_deck)
    expect(v.validations.size).to eq(0)
  end

  it 'initializes validations properly' do
    v = described_class.new(invalid_with_multiple_validations)
    expect(v.validations.size).to eq(2)

    expect(v.validations[0].label).to eq('validation 1')
    expect(v.validations[0].basic_deckbuilding_rules).to be_falsey
    expect(v.validations[1].label).to eq('validation 2')
    expect(v.validations[1].basic_deckbuilding_rules).to be_truthy
  end

  describe 'validation without basic deckbuilding rules' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    it 'validates corp deck' do
      v = described_class.new(good_asa_without_basic_deckbuilding_validations)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(good_asa_without_basic_deckbuilding_validations['validations'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end

    it 'validates runner deck' do
      v = described_class.new(bad_ken_without_basic_deckbuilding_rules)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(bad_ken_without_basic_deckbuilding_rules['validations'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end
  end

  describe 'good decks' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    it 'validates a good corp deck' do
      v = described_class.new(good_asa_group)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(good_asa_group['validations'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end

    it 'validates a good ampere deck' do
      v = described_class.new(good_ampere)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(good_ampere['validations'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end

    it 'validates a good runner deck' do
      v = described_class.new(good_ken)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(good_ken['validations'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end

    it 'validates a good nova deck' do
      v = described_class.new(good_nova)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(good_nova['validations'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end

    it 'validates a good professor deck' do
      v = described_class.new(good_professor)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(good_professor['validations'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end

    it 'is idempotent when calling valid? repeatedly' do
      v = described_class.new(too_much_program_influence_professor)
      6.times do
        expect(v).not_to be_valid
        expect(v.errors.size).to eq(0)
        expect(v.validations.size).to eq(too_much_program_influence_professor['validations'].size)
        expect(v.validations[0].errors.size).to eq(1)
      end
    end

    it 'normalizes case' do
      v = described_class.new(upper_case_asa_group)
      expect(v).to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(upper_case_asa_group['VALIDATIONS'].size)
      expect(v.validations[0]).to be_valid
      expect(v.validations[0].errors.size).to eq(0)
    end
  end

  describe 'bad decks' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    it 'does not allow corp identities as cards' do
      deck = swap_card(good_ampere.deep_dup, 'ark_lockdown', 'asa_group_security_through_vigilance')
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include(
        'Decks may not include multiple identities.  Identity card `asa_group_security_through_vigilance` is not allowed.' # rubocop:disable Layout/LineLength
      )
    end

    it 'does not allow runner identities as cards' do
      deck = good_nova.deep_dup
      deck['cards']['armand_geist_walker_tech_lord'] = 3
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include(
        'Decks may not include multiple identities.  Identity card `armand_geist_walker_tech_lord` is not allowed.'
      )
    end

    it 'detects too much program influence for professor' do
      v = described_class.new(too_much_program_influence_professor)
      expect(v).not_to be_valid
      expect(v.errors.size).to eq(0)
      expect(v.validations.size).to eq(too_much_program_influence_professor['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include(
        'Influence limit for The Professor: Keeper of Knowledge is 1, but deck has spent 9 influence'
      )
    end

    it 'fails validation for empty deck json' do
      v = described_class.new(empty_deck)
      expect(v).not_to be_valid, 'Empty Deck JSON fails validation'
      expect(v.errors).to include('Deck is missing `identity_card_id` field.')
      expect(v.errors).to include('Deck is missing `side_id` field.')
      expect(v.errors).to include('Deck must specify some cards.')
      expect(v.errors).to include('Validation request must specify at least one validation to perform.')
    end

    it 'fails validation for deck json missing identity' do
      v = described_class.new(missing_identity)
      expect(v).not_to be_valid, 'Deck JSON missing identity fails validation'
      expect(v.errors).to include('Deck is missing `identity_card_id` field.')
    end

    it 'fails validation for deck json missing side' do
      v = described_class.new(missing_side)
      expect(v).not_to be_valid, 'Deck JSON missing side fails validation'
      expect(v.errors).to include('Deck is missing `side_id` field.')
    end

    it 'fails validation for deck json with non-existent identity' do
      v = described_class.new(imaginary_identity)
      expect(v).not_to be_valid, 'Deck JSON has non-existent Identity'
      expect(v.errors).to include('`identity_card_id` `plural` does not exist.')
    end

    it 'fails validation for deck json with non-existent side' do
      v = described_class.new(imaginary_side)
      expect(v).not_to be_valid, 'Deck JSON has non-existent side'
      expect(v.errors).to include('`side_id` `super_mega_corp` does not exist.')
    end

    it 'fails validation for corp deck with runner card' do
      v = described_class.new(runner_econ_asa_group)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(runner_econ_asa_group['validations'].size)
      expect(v.validations[0]).not_to be_valid, 'Basic deckbuilding validation fails.'
      expect(v.validations[0].errors).to include('Card `sure_gamble` side `runner` does not match deck side `corp`')
    end

    it 'fails validation for out of faction agendas' do
      v = described_class.new(out_of_faction_agenda)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(out_of_faction_agenda['validations'].size)
      expect(v.validations[0]).not_to be_valid, 'Basic deckbuilding validation fails.'
      expect(v.validations[0].errors).to include(
        'Agenda `bellona` with faction_id `nbn` is not allowed in a `haas_bioroid` deck.'
      )
    end

    it 'fails validation for out of faction agendas in ampere deck' do
      v = described_class.new(ampere_too_many_agendas_from_one_faction)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(ampere_too_many_agendas_from_one_faction['validations'].size)
      expect(v.validations[0]).not_to be_valid, 'Basic deckbuilding validation fails.'
      expect(v.validations[0].errors).to include(
        'Ampere decks may not include more than 2 agendas per non-neutral faction. There are 3 `nbn` agendas present.'
      )
    end

    it 'fails validation for runner deck with corp card' do
      v = described_class.new(corp_econ_ken)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(corp_econ_ken['validations'].size)
      expect(v.validations[0]).not_to be_valid, 'Runner deck with corp card fails.'
      expect(v.validations[0].errors).to include('Card `hedge_fund` side `corp` does not match deck side `runner`')
    end

    it 'fails validation for deck with mismatched id and specified side' do
      v = described_class.new(wrong_side_geist)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(wrong_side_geist['validations'].size)
      expect(v.validations[0]).not_to be_valid, 'Deck with mismatched id and specified side fails'
      expect(v.validations[0].errors).to include(
        'Identity `armand_geist_walker_tech_lord` has side `runner` which does not match given side `corp`'
      )
    end

    it 'fails validation for deck with not enough agenda points' do
      v = described_class.new(not_enough_agenda_points_too_many_copies)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(not_enough_agenda_points_too_many_copies['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include('Deck with size 45 requires [20,21] agenda points, but deck only has 18') # rubocop:disable Layout/LineLength
    end

    it 'fails validation for deck with too many copies of a card' do
      v = described_class.new(not_enough_agenda_points_too_many_copies)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(not_enough_agenda_points_too_many_copies['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include('Card `hedge_fund` has a deck limit of 3, but 36 copies are included.')
      expect(v.validations[0].errors).to include('Card `project_vitruvius` has a deck limit of 3, but 9 copies are included.') # rubocop:disable Layout/LineLength
    end

    it 'fails validation for ampere deck with too many copies' do
      v = described_class.new(ampere_with_too_many_cards)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(ampere_with_too_many_cards['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include('Card `hedge_fund` has a deck limit of 1, but 2 copies are included.')
      expect(v.validations[0].errors).to include('Card `tyr` has a deck limit of 1, but 2 copies are included.')
    end

    it 'fails validation for nova deck with too many copies' do
      v = described_class.new(nova_with_too_many_cards)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(nova_with_too_many_cards['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include('Card `sure_gamble` has a deck limit of 1, but 2 copies are included.')
      expect(v.validations[0].errors).to include('Card `unity` has a deck limit of 1, but 2 copies are included.')
    end

    it 'fails validation for deck with too much influence for corp' do
      v = described_class.new(too_much_influence_asa_group)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(too_much_influence_asa_group['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'
      )
    end

    it 'fails validation for deck with bad cards' do
      v = described_class.new(bad_cards_asa_group)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(bad_cards_asa_group['validations'].size)
      expect(v.errors).to include('Card `foo` does not exist.')
      expect(v.errors).to include('Card `bar` does not exist.')
    end

    it 'fails validation for too few cards' do
      v = described_class.new(too_few_cards_asa_group)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(too_few_cards_asa_group['validations'].size)
      expect(v.validations[0]).not_to be_valid
      expect(v.validations[0].errors).to include('Minimum deck size is 45, but deck has 3 cards.')
    end

    it 'fails validation for invalid format id' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['format_id'] = 'magic_the_gathering'
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      # TODO: Update validation to explicitly set valid? to false
      # and have the validator set it to true as a literal iff valid.
      expect(v.errors).to include('Format `magic_the_gathering` does not exist.')
    end

    it 'fails validation for invalid card pool id' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['card_pool_id'] = 'startup_2099'
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.errors).to include('Card Pool `startup_2099` does not exist.')
    end

    it 'fails validation for invalid restriction id' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['restriction_id'] = 'standard_banlist_2034_03'
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.errors).to include('Restriction `standard_banlist_2034_03` does not exist.')
    end

    it 'fails validation for invalid snapshot id' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['snapshot_id'] = 'snapshot_3030'
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.errors).to include('Snapshot `snapshot_3030` does not exist.')
    end

    it 'fails validation for cards not in specified card pool' do
      deck = good_asa_group.deep_dup
      # Test fixture standard_02 is not a full representation of standard.
      deck['validations'][0]['card_pool_id'] = 'standard_02'
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      # Ensure all invalid cards are reported as errors.
      %w[
        ansel_1_0
        biotic_labor
        eli_1_0
        enigma
        hagen
        hakarl_1_0
        ikawah_project
        project_vitruvius
        regolith_mining_license
        rototurret
        spin_doctor
        tollbooth
      ].each do |c|
        expect(v.validations[0].errors).to include("Card `#{c}` is not present in Card Pool `standard_02`.")
      end
    end

    it 'fails validation for banned card' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['format_id'] = 'standard'
      deck['validations'][0].delete('card_pool_id')
      deck['validations'][0].delete('restriction_id')
      deck['validations'][0].delete('snapshot_id')

      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include('Card `trieste_model_bioroids` is banned in restriction `standard_banlist`.') # rubocop:disable Layout/LineLength
    end

    it 'fails validation for too many restricted cards' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['restriction_id'] = 'standard_restricted'
      deck['validations'][0].delete('card_pool_id')
      deck['validations'][0].delete('format_id')
      deck['validations'][0].delete('snapshot_id')

      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Deck has too many cards marked restricted in restriction `standard_restricted`: send_a_message, trieste_model_bioroids.' # rubocop:disable Layout/LineLength
      )
    end

    it 'fails validation for global penalty reduces influence' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['restriction_id'] = 'standard_global_penalty'
      deck['validations'][0].delete('format_id')
      deck['validations'][0].delete('card_pool_id')
      deck['validations'][0].delete('snapshot_id')

      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 13 after Global Penalty applied from restriction `standard_global_penalty`, but deck has spent 2 influence from tyr (2).' # rubocop:disable Layout/LineLength
      )
    end

    it 'fails validation for universal influence' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['restriction_id'] = 'standard_universal_faction_cost'
      deck['validations'][0].delete('format_id')
      deck['validations'][0].delete('card_pool_id')
      deck['validations'][0].delete('snapshot_id')

      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 15, but after Universal Influence applied from restriction `standard_universal_faction_cost`, deck has spent 24 influence from punitive_counterstrike (9).' # rubocop:disable Layout/LineLength
      )
    end

    it 'fails validation for over eternal points limit' do
      deck = good_asa_group.deep_dup
      deck['validations'][0]['snapshot_id'] = 'eternal_01'
      deck['validations'][0].delete('card_pool_id')
      deck['validations'][0].delete('format_id')
      deck['validations'][0].delete('restriction_id')

      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Deck has too many points (9) for eternal restriction `eternal_points_list`: send_a_message (3), punitive_counterstrike (3), tyr (3).' # rubocop:disable Layout/LineLength
      )
    end

    # Mumba Temple costs 0 instead of 2 influence if the deck has >= 15 ice
    it 'fails validation for mumba temple' do
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
      deck = swap_card(
        swap_card(swap_card(good_asa_group.deep_dup, 'hagen', 'mumba_temple'), 'hakarl_1_0',
                  'ark_lockdown'), 'ansel_1_0', 'prisec'
      )
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'
      )

      deck = swap_card(good_asa_group.deep_dup, 'hagen', 'mumba_temple')
      v = described_class.new(deck)
      expect(v).to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
    end

    # Mumbad Virtual Tour costs 0 instead of 2 influence if the deck has >= 7 assets
    it 'fails validation for mumbad virtual tour' do
      # Swap 3 cards for Museum of History, deck under 50 should fail.
      deck = swap_card(swap_card(good_asa_group.deep_dup, 'hagen', 'mumbad_virtual_tour'), 'trieste_model_bioroids',
                       'ark_lockdown')
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'
      )

      deck = swap_card(good_asa_group.deep_dup, 'hagen', 'mumbad_virtual_tour')
      v = described_class.new(deck)
      expect(v).to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
    end

    # Museum costs 0 instead of 2 influence if the deck has >= 50 cards
    it 'fails validation for museum of history' do
      # Swap 3 cards for Museum of History, deck under 50 should fail.
      deck = swap_card(good_asa_group.deep_dup, 'hagen', 'museum_of_history')
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'
      )

      deck = good_asa_group.deep_dup
      deck['cards']['ontological_dependence'] = 1
      deck['cards']['museum_of_history'] = 3
      v = described_class.new(deck)
      expect(v).to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
    end

    # Pad factory costs 0 instead of 2 influence if the deck has 3 pad campaigns.
    it 'fails validation for pad factory' do
      # swap 3 cards for a pad factory, no pad campaigns, should add 6 influence.
      deck = swap_card(good_asa_group.deep_dup, 'hagen', 'pad_factory')
      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence'
      )

      # swap 3 cards for pad factory, add 3 pad campaigns, influence should be fine.
      deck = swap_card(swap_card(good_asa_group.deep_dup, 'hagen', 'pad_factory'), 'hakarl_1_0', 'pad_campaign')
      v = described_class.new(deck)
      expect(v).to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
    end

    it 'fails validation for alliance faction locked' do
      deck = swap_card(swap_card(good_asa_group, 'tollbooth', 'afshar'), 'tyr', 'consulting_visit')
      deck['cards']['afshar'] = 2
      deck['cards']['consulting_visit'] = 3
      deck['cards'].delete('rototurret')

      v = described_class.new(deck)
      expect(v).not_to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
      expect(v.validations[0].errors).to include(
        'Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 22 influence'
      )

      # With 3 Afshar and 3 Punitive Counterstrike, there are 6 non-Alliance Weyland cards in the deck.
      deck['cards']['afshar'] = 3
      v = described_class.new(deck)
      expect(v).to be_valid
      expect(v.validations.size).to eq(deck['validations'].size)
    end
  end
end
