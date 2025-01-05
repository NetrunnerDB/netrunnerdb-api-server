# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardResource, type: :resource do
  describe 'serialization' do
    let!(:card) { Card.find('the_class_act') }

    it 'fields match' do
      params[:filter] = { id: { eq: card.id } }
      render

      data = jsonapi_data[0]
      expect(data.advancement_requirement).to eq(card.advancement_requirement)
      expect(data.agenda_points).to eq(card.agenda_points)
      expect(data.attribution).to eq(card.attribution)
      expect(data.base_link).to eq(card.base_link)
      expect(data.card_abilities).to eq(card.card_abilities.stringify_keys)
      expect(data.card_cycle_ids).to eq(card.card_cycle_ids)
      expect(data.card_pool_ids).to eq(card.card_pool_ids)
      expect(data.card_set_ids).to eq(card.card_set_ids)
      expect(data.card_subtype_ids).to eq(card.card_subtype_ids)
      expect(data.card_type_id).to eq(card.card_type_id)
      expect(data.cost).to eq(card.cost.to_s)
      expect(data.date_release).to eq(card.date_release.strftime('%Y-%m-%d'))
      expect(data.deck_limit).to eq(card.deck_limit)
      expect(data.designed_by).to eq(card.designed_by)
      expect(data.display_subtypes).to eq(card.display_subtypes)
      expect(data.faction_id).to eq(card.faction_id)
      expect(data.format_ids).to eq(card.format_ids)
      expect(data.id).to eq(card.id)
      expect(data.in_restriction).to eq(card.in_restriction)
      expect(data.influence_cost).to eq(card.influence_cost)
      expect(data.influence_limit).to eq(card.influence_limit)
      expect(data.is_unique).to eq(card.is_unique)
      expect(data.latest_printing_id).to eq(card.latest_printing_id)
      expect(data.memory_cost).to eq(card.memory_cost)
      expect(data.minimum_deck_size).to eq(card.minimum_deck_size)
      expect(data.num_printings).to eq(card.num_printings)
      expect(data.printing_ids).to eq(card.printing_ids)
      expect(data.printings_released_by).to match_array(card.printings_released_by)
      expect(data.pronouns).to eq(card.pronouns)
      expect(data.pronunciation_approximation).to eq(card.pronunciation_approximation)
      expect(data.pronunciation_ipa).to eq(card.pronunciation_ipa)
      expect(data.restriction_ids).to eq(card.restriction_ids)
      expect(data.restrictions).to eq(card.restrictions.stringify_keys)
      expect(data.side_id).to eq(card.side_id)
      expect(data.snapshot_ids).to eq(card.snapshot_ids)
      expect(data.strength).to eq(card.strength)
      expect(data.stripped_text).to eq(card.stripped_text)
      expect(data.stripped_title).to eq(card.stripped_title)
      expect(data.text).to eq(card.text)
      expect(data.title).to eq(card.title)
      expect(data.trash_cost).to eq(card.trash_cost)
      expect(data.updated_at).to eq(card.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('cards')
    end
  end

  describe 'multiple_faces' do
    let!(:card) { Card.find('hoshiko_shiro_untold_protagonist') }

    it 'fields match' do
      params[:filter] = { id: { eq: card.id } }
      render

      data = jsonapi_data[0]
      expect(data.num_extra_faces).to eq(card.num_extra_faces)
      expect(data.faces[0][:display_subtypes]).to eq(card.faces_display_subtypes[0])
    end
  end

  describe 'filtering' do
    let!(:card) { Card.find('pennyshaver') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: card.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([card.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(card_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: card_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include card cycles' do
      let!(:card) { Card.find('steelskin_scarring') }
      let!(:card_cycle) { CardCycle.find('borealis') }

      it 'is properly included' do
        check_included_for_id(card.id, 'card_cycles', 'card_cycles', card_cycle.id)
      end
    end

    describe 'include card sets' do
      let!(:card) { Card.find('steelskin_scarring') }
      let!(:card_set) { CardSet.find('midnight_sun') }

      it 'is properly included' do
        check_included_for_id(card.id, 'card_sets', 'card_sets', card_set.id)
      end
    end

    describe 'include card subtypes' do
      let!(:card) { Card.find('adonis_campaign') }
      let!(:card_subtype) { CardSubtype.find('advertisement') }

      it 'is properly included' do
        check_included_for_id(card.id, 'card_subtypes', 'card_subtypes', card_subtype.id)
      end
    end

    describe 'include card type' do
      let!(:card) { Card.find('send_a_message') }
      let!(:card_type) { CardType.find('agenda') }

      it 'is properly included' do
        check_included_for_id(card.id, 'card_type', 'card_types', card_type.id)
      end
    end

    describe 'include decklists' do
      let!(:card) { Card.find('pinhole_threading') }
      let!(:decklist) { Decklist.find('22222222-2222-2222-2222-222222222222') }

      it 'is properly included' do
        check_included_for_id(card.id, 'decklists', 'decklists', decklist.id)
      end
    end

    describe 'include faction' do
      let!(:card) { Card.find('surveyor') }
      let!(:faction) { Faction.find('weyland_consortium') }

      it 'is properly included' do
        check_included_for_id(card.id, 'faction', 'factions', faction.id)
      end
    end

    describe 'include printings' do
      let!(:card) { Card.find('hostile_takeover') }
      let!(:printing) { Printing.find('21132') }

      it 'is properly included' do
        check_included_for_id(card.id, 'printings', 'printings', printing.id)
      end
    end

    describe 'include reviews' do
      let!(:card) { Card.find('endurance') }
      let!(:review) { Review.find(1) }

      it 'is properly included' do
        check_included_for_id(card.id, 'reviews', 'reviews', review.id.to_s)
      end
    end

    describe 'include rulings' do
      let!(:card) { Card.find('hedge_fund') }
      let!(:ruling) { Ruling.find(1) }

      it 'is properly included' do
        check_included_for_id(card.id, 'rulings', 'rulings', ruling.id.to_s)
      end
    end

    describe 'include side' do
      let!(:card) { Card.find('urban_renewal') }
      let!(:side) { Side.find('corp') }

      it 'is properly included' do
        check_included_for_id(card.id, 'side', 'sides', side.id)
      end
    end

    describe 'include card_pools' do
      let!(:card) { Card.find('border_control') }
      let!(:card_pool) { CardPool.find('eternal_01') }

      it 'is properly included' do
        check_included_for_id(card.id, 'card_pools', 'card_pools', card_pool.id)
      end
    end
  end
end
