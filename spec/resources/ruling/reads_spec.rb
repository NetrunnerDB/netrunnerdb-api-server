# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RulingResource, type: :resource do
  describe 'serialization' do
    let!(:ruling) { Ruling.find(1) }

    it 'works' do
      params[:filter] = { id: { eq: ruling.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(ruling.id)
      expect(data.card_id).to eq(ruling.card_id)
      expect(data.nsg_rules_team_verified).to eq(ruling.nsg_rules_team_verified)
      expect(data.question).to eq(ruling.question)
      expect(data.answer).to eq(ruling.answer)
      expect(data.text_ruling).to eq(ruling.text_ruling)
      expect(data.updated_at).to eq(ruling.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('rulings')
    end
  end

  describe 'filtering' do
    let!(:ruling) { Ruling.find(2) }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: ruling.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([ruling.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(ruling_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: ruling_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include card' do
      let!(:ruling) { Ruling.find(1) }
      let!(:card) { Card.find('hedge_fund') }

      it 'works' do
        check_included_for_id(ruling.id, 'card', 'cards', card.id)
      end
    end
  end
end
