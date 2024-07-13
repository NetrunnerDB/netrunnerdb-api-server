# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FactionResource, type: :resource do
  describe 'serialization' do
    let!(:faction) { Faction.find('shaper') }

    it 'works' do
      params[:filter] = { id: { eq: faction.id } }
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(faction.id)
      expect(data.name).to eq(faction.name)
      expect(data.description).to eq(faction.description)
      expect(data.is_mini).to eq(faction.is_mini)
      expect(data.side_id).to eq(faction.side_id)
      expect(data.updated_at).to eq(faction.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('factions')
    end
  end

  describe 'filtering' do
    let!(:faction) { Faction.find('shaper') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: faction.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([faction.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(faction_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: faction_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include cards' do
      let!(:faction) { Faction.find('neutral_runner') }
      let!(:sure_gamble) { Card.find('sure_gamble') }

      it 'works' do
        check_included_for_id(faction.id, 'cards', 'cards', sure_gamble.id)
      end
    end

    # describe 'include decklists' do
    #   let!(:faction) { Faction.find('haas_bioroid') }
    #   let!(:asa_deck) { Decklist.find('11111111-1111-1111-1111-111111111111') }

    #   it 'works' do
    #     check_included_for_id(faction.id, 'decklists', asa_deck.id)
    #   end
    # end

    describe 'include printings' do
      let!(:faction) { Faction.find('jinteki') }
      let!(:urtica) { Printing.find('21179') }

      it 'works' do
        check_included_for_id(faction.id, 'printings', 'printings', urtica.id)
      end
    end

    describe 'include side' do
      let!(:faction) { Faction.find('nbn') }
      let!(:corp) { Side.find('corp') }

      it 'works' do
        check_included_for_id(faction.id, 'side', 'sides', corp.id)
      end
    end

  end
end
