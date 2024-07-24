# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DecklistResource, type: :resource do
  describe 'serialization' do
    let!(:decklist) { Decklist.find('22222222-2222-2222-2222-222222222222') }

    it 'works' do
      params[:filter] = { id: { eq: decklist.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(decklist.id)
      expect(data.user_id).to eq(decklist.user_id)
      expect(data.side_id).to eq(decklist.side_id)
      expect(data.faction_id).to eq(decklist.faction_id)
      expect(data.follows_basic_deckbuilding_rules).to eq(decklist.follows_basic_deckbuilding_rules)
      expect(data.identity_card_id).to eq(decklist.identity_card_id)
      expect(data.name).to eq(decklist.name)
      expect(data.notes).to eq(decklist.notes)
      expect(data.tags).to eq(decklist.tags)
      expect(data.card_slots).to eq(decklist.card_slots)
      expect(data.num_cards).to eq(decklist.num_cards)
      expect(data.influence_spent).to eq(decklist.influence_spent)
      expect(data.created_at).to eq(decklist.created_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.updated_at).to eq(decklist.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('decklists')
    end
  end

  describe 'filtering' do
    let!(:decklist) { Decklist.find('11111111-1111-1111-1111-111111111111') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: decklist.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([decklist.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(decklist_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: decklist_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include side' do
      let!(:decklist) { Decklist.find('11111111-1111-1111-1111-111111111111') }
      let!(:side) { Side.find('corp') }

      it 'works' do
        check_included_for_id(decklist.id, 'side', 'sides', side.id)
      end
    end

    describe 'include faction' do
      let!(:decklist) { Decklist.find('22222222-2222-2222-2222-222222222222') }
      let!(:faction) { Faction.find('criminal') }

      it 'works' do
        check_included_for_id(decklist.id, 'faction', 'factions', faction.id)
      end
    end

    describe 'include identity card' do
      let!(:decklist) { Decklist.find('11111111-1111-1111-1111-111111111111') }
      let!(:card) { Card.find('asa_group_security_through_vigilance') }

      it 'works' do
        check_included_for_id(decklist.id, 'identity_card', 'cards', card.id)
      end
    end

    describe 'include cards' do
      let!(:decklist) { Decklist.find('22222222-2222-2222-2222-222222222222') }
      let!(:card) { Card.find('the_class_act') }

      it 'works' do
        check_included_for_id(decklist.id, 'cards', 'cards', card.id)
      end
    end
  end
end
