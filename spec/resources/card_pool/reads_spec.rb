# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardPoolResource, type: :resource do
  describe 'serialization' do
    let!(:standard) { CardPool.find('standard_02') }

    it 'works' do
      params[:filter] = { id: { eq: standard.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(standard.id)
      expect(data.name).to eq(standard.name)
      expect(data.format_id).to eq(standard.format_id)
      expect(data.card_cycle_ids).to eq(standard.card_cycle_ids)
      expect(data.num_cards).to eq(standard.num_cards)
      expect(data.updated_at).to eq(standard.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('card_pools')
    end
  end

  describe 'filtering' do
    let!(:eternal) { CardPool.find('eternal_01') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: eternal.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([eternal.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(card_pool_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: card_pool_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include format' do
      let!(:card_pool) { CardPool.find('startup_02') }
      let!(:startup) { Format.find('startup') }

      it 'works' do
        check_included_for_id(card_pool.id, 'format', 'formats', startup.id)
      end
    end

    describe 'include card cycles' do
      let!(:card_pool) { CardPool.find('standard_02') }
      let!(:borealis) { CardCycle.find('borealis') }

      it 'works' do
        check_included_for_id(card_pool.id, 'card_cycles', 'card_cycles', borealis.id)
      end
    end

    describe 'include card sets' do
      let!(:card_pool) { CardPool.find('standard_02') }
      let!(:midnight_sun) { CardSet.find('midnight_sun') }

      it 'works' do
        check_included_for_id(card_pool.id, 'card_sets', 'card_sets', midnight_sun.id)
      end
    end

    describe 'include snapshots' do
      let!(:card_pool) { CardPool.find('standard_02') }
      let!(:snapshot) { Snapshot.find('standard_04') }

      it 'works' do
        check_included_for_id(card_pool.id, 'snapshots', 'snapshots', snapshot.id)
      end
    end

    describe 'include cards' do
      let!(:card_pool) { CardPool.find('eternal_01') }
      let!(:card) { Card.find('border_control') }

      it 'works' do
        check_included_for_id(card_pool.id, 'cards', 'cards', card.id)
      end
    end

    describe 'include cards' do
      let!(:card_pool) { CardPool.find('eternal_01') }
      let!(:printing) { Printing.find(Card.find('border_control').latest_printing_id) }

      it 'works' do
        check_included_for_id(card_pool.id, 'printings', 'printings', printing.id)
      end
    end
  end
end
