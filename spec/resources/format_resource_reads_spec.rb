# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormatResource, type: :resource do
  describe 'serialization' do
    let!(:format) { Format.find('standard') }

    it 'works' do
      params[:filter] = { id: { eq: format.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(format.id)
      expect(data.name).to eq(format.name)
      expect(data.active_snapshot_id).to eq(format.active_snapshot_id)
      expect(data.snapshot_ids).to eq(format.snapshot_ids)
      expect(data.restriction_ids).to eq(format.restriction_ids)
      expect(data.active_card_pool_id).to eq(format.active_card_pool_id)
      expect(data.active_restriction_id).to eq(format.active_restriction_id)
      expect(data.updated_at).to eq(format.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('formats')
    end
  end

  describe 'filtering' do
    let!(:format) { Format.find('startup') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: format.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([format.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(format_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: format_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include card pools' do
      let!(:format) { Format.find('standard') }
      let!(:card_pool) { CardPool.find('standard_02') }

      it 'works' do
        check_included_for_id(format.id, 'card_pools', 'card_pools', card_pool.id)
      end
    end

    describe 'include restrictions' do
      let!(:format) { Format.find('standard') }
      let!(:restriction) { Restriction.find('standard_global_penalty') }

      it 'works' do
        check_included_for_id(format.id, 'restrictions', 'restrictions', restriction.id)
      end
    end

    describe 'include snapshots' do
      let!(:format) { Format.find('standard') }
      let!(:snapshot) { Snapshot.find('standard_05') }

      it 'works' do
        check_included_for_id(format.id, 'snapshots', 'snapshots', snapshot.id)
      end
    end
  end
end
