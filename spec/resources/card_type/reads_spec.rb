# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardTypeResource, type: :resource do
  describe 'serialization' do
    let!(:card_type) { CardType.find('program') }

    it 'works' do
      params[:filter] = { id: { eq: card_type.id } }
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(card_type.id)
      expect(data.name).to eq(card_type.name)
      expect(data.updated_at).to eq(card_type.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('card_types')
    end
  end

  describe 'filtering' do
    let!(:card_type) { CardType.find('ice') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: card_type.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([card_type.id])
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
      let!(:card_type) { CardType.find('event') }
      let!(:sure_gamble) { Card.find('sure_gamble') }

      it 'works' do
        check_included_for_id(card_type.id, 'cards', 'cards', sure_gamble.id)
      end
    end

    describe 'include printings' do
      let!(:card_type) { CardType.find('asset') }
      let!(:urtica) { Printing.find('21179') }

      it 'works' do
        check_included_for_id(card_type.id, 'printings', 'printings', urtica.id)
      end
    end

    describe 'include side' do
      let!(:card_type) { CardType.find('agenda') }
      let!(:corp) { Side.find('corp') }

      it 'works' do
        check_included_for_id(card_type.id, 'side', 'sides', corp.id)
      end
    end
  end
end
