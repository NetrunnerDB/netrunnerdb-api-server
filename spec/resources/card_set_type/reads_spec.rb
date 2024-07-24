# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardSetTypeResource, type: :resource do
  describe 'serialization' do
    let!(:booster_pack) { CardSetType.find('booster_pack') }

    it 'works' do
      params[:filter] = { id: { eq: booster_pack.id } }
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(booster_pack.id)
      expect(data.name).to eq(booster_pack.name)
      expect(data.description).to eq(booster_pack.description)
      expect(data.updated_at).to eq(booster_pack.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
    end
  end

  describe 'filtering' do
    let!(:core_set) { CardSetType.find('core') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: core_set.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([core_set.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(object_id, resource_type, sideloaded_id)
      params[:filter] = { id: { eq: object_id } }
      params[:include] = resource_type
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(sideloaded_id)
    end

    describe 'include card sets' do
      let!(:booster_pack) { CardSetType.find('booster_pack') }
      let!(:midnight_sun) { CardSet.find('midnight_sun') }

      it 'works' do
        check_included_for_id(booster_pack.id, 'card_sets', midnight_sun.id)
      end
    end
  end
end
