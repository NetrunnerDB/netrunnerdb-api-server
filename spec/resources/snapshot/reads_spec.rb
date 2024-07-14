# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SnapshotResource, type: :resource do
  describe 'serialization' do
    let!(:snapshot) { Snapshot.find('startup_02') }

    it 'works' do
      params[:filter] = { id: { eq: snapshot.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(snapshot.id)
      expect(data.format_id).to eq(snapshot.format_id)
      expect(data.active).to eq(snapshot.active)
      expect(data.card_cycle_ids).to eq(snapshot.card_cycle_ids)
      expect(data.card_set_ids).to eq(snapshot.card_set_ids)
      expect(data.card_pool_id).to eq(snapshot.card_pool_id)
      expect(data.restriction_id).to eq(snapshot.restriction_id)
      expect(data.num_cards).to eq(snapshot.num_cards)
      expect(data.date_start).to eq(snapshot.date_start)
      expect(data.updated_at).to eq(snapshot.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('snapshots')
    end
  end

  describe 'filtering' do
    let!(:snapshot) { Snapshot.find('eternal_01') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: snapshot.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([snapshot.id])
      end
    end
  end

  # Format, card pool, restriction

  describe 'sideloading' do
    def check_included_for_id(snapshot_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: snapshot_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include format' do
      let!(:snapshot) { Snapshot.find('eternal_01') }
      let!(:format) { Format.find('eternal') }

      it 'works' do
        check_included_for_id(snapshot.id, 'format', 'formats', format.id)
      end
    end

    describe 'include card_pool' do
      let!(:snapshot) { Snapshot.find('startup_01') }
      let!(:card_pool) { CardPool.find('startup_01') }

      it 'works' do
        check_included_for_id(snapshot.id, 'card_pool', 'card_pools', card_pool.id)
      end
    end

    describe 'include restriction' do
      let!(:snapshot) { Snapshot.find('standard_05') }
      let!(:restriction) { Restriction.find('standard_universal_faction_cost') }

      it 'works' do
        check_included_for_id(snapshot.id, 'restriction', 'restrictions', restriction.id)
      end
    end
  end
end
