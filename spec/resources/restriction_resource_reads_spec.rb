# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RestrictionResource, type: :resource do
  describe 'serialization' do
    let!(:restriction) { Restriction.find('standard_global_penalty') }

    it 'works' do
      params[:filter] = { id: { eq: restriction.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(restriction.id)
      expect(data.date_start).to eq(restriction.date_start)
      expect(data.point_limit).to eq(restriction.point_limit)
      expect(data.format_id).to eq(restriction.format_id)
      expect(data.banned_subtypes).to eq(restriction.banned_subtype_ids)
      expect(data.verdicts).to eq(restriction.verdicts.stringify_keys)
      expect(data.size).to eq(restriction.size)
      expect(data.updated_at).to eq(restriction.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('restrictions')
    end
  end

  describe 'filtering' do
    let!(:restriction) { Restriction.find('standard_restricted') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: restriction.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([restriction.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(restriction_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: restriction_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include format' do
      let!(:restriction) { Restriction.find('eternal_points_list') }
      let!(:format) { Format.find('eternal') }

      it 'works' do
        check_included_for_id(restriction.id, 'format', 'formats', format.id)
      end
    end
  end
end
