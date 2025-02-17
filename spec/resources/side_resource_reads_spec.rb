# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SideResource, type: :resource do
  describe 'serialization' do
    let!(:side) { Side.find('corp') }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(side.id)
      expect(data.name).to eq(side.name)
      expect(data.updated_at).to eq(side.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('sides')
    end
  end

  describe 'filtering' do
    let!(:side) { Side.find('corp') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: side.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([side.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(side_id, resource_type, id)
      params[:filter] = { id: { eq: side_id } }
      params[:include] = resource_type
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include card types' do
      let!(:side) { Side.find('corp') }
      let!(:agenda) { CardType.find('agenda') }

      it 'works' do
        check_included_for_id(side.id, 'card_types', agenda.id)
      end
    end

    describe 'include cards' do
      let!(:side) { Side.find('runner') }
      let!(:sure_gamble) { Card.find('sure_gamble') }

      it 'works' do
        check_included_for_id(side.id, 'cards', sure_gamble.id)
      end
    end

    describe 'include decklists' do
      let!(:side) { Side.find('corp') }
      let!(:asa_deck) { Decklist.find('11111111-1111-1111-1111-111111111111') }

      it 'works' do
        check_included_for_id(side.id, 'decklists', asa_deck.id)
      end
    end

    describe 'include factions' do
      let!(:side) { Side.find('runner') }
      let!(:anarch) { Faction.find('anarch') }

      it 'works' do
        check_included_for_id(side.id, 'factions', anarch.id)
      end
    end

    describe 'include printings' do
      let!(:side) { Side.find('corp') }
      let!(:urtica) { Printing.find('21179') }

      it 'works' do
        check_included_for_id(side.id, 'printings', urtica.id)
      end
    end
  end
end
