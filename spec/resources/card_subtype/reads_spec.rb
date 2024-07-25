# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardSubtypeResource, type: :resource do
  describe 'serialization' do
    let!(:card_subtype) { CardSubtype.find('advertisement') }

    it 'works' do
      params[:filter] = { id: { eq: card_subtype.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(card_subtype.id)
      expect(data.name).to eq(card_subtype.name)
      expect(data.updated_at).to eq(card_subtype.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('card_subtypes')
    end
  end

  describe 'filtering' do
    let!(:card_subtype) { CardSubtype.find('advertisement') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: card_subtype.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([card_subtype.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(card_subtype_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: card_subtype_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include cards' do
      let!(:card_subtype) { CardSubtype.find('advertisement') }
      let!(:adonis_campaign) { Card.find('adonis_campaign') }

      it 'works' do
        check_included_for_id(card_subtype.id, 'cards', 'cards', adonis_campaign.id)
      end
    end

    describe 'include printings' do
      let!(:card_subtype) { CardSubtype.find('killer') }
      let!(:bukhgalter) { Printing.find('21095') }

      it 'works' do
        check_included_for_id(card_subtype.id, 'printings', 'printings', bukhgalter.id)
      end
    end
  end
end
