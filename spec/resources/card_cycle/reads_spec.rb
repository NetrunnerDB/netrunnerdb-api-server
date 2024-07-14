# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardCycleResource, type: :resource do
  describe 'serialization' do
    let!(:borealis) { CardCycle.find('borealis') }

    it 'works' do
      params[:filter] = { id: { eq: borealis.id } }
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(borealis.id)
      expect(data.name).to eq(borealis.name)
      expect(data.date_release).to eq(borealis.date_release.strftime('%Y-%m-%d'))
      expect(data.legacy_code).to eq(borealis.legacy_code)
      expect(data.position).to eq(borealis.position)
      expect(data.updated_at).to eq(borealis.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
    end
  end

  describe 'filtering' do
    let!(:core_set) { CardCycle.find('core') }

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
      let!(:borealis) { CardCycle.find('borealis') }
      let!(:parhelion) { CardSet.find('parhelion') }

      it 'works' do
        check_included_for_id(borealis.id, 'card_sets', parhelion.id)
      end
    end

    describe 'include cards' do
      let!(:borealis) { CardCycle.find('core') }
      let!(:legwork) { Card.find('legwork') }

      it 'works' do
        check_included_for_id(borealis.id, 'cards', legwork.id)
      end
    end

    describe 'include printings' do
      let!(:borealis) { CardCycle.find('borealis') }
      let!(:steelskin) { Printing.find('21166') }

      it 'works' do
        check_included_for_id(borealis.id, 'printings', steelskin.id)
      end
    end
  end
end
