# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardSetResource, type: :resource do
  describe 'serialization' do
    let!(:midnight_sun) { CardSet.find('midnight_sun') }

    it 'works' do
      params[:filter] = { id: { eq: midnight_sun.id } }
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(midnight_sun.id)
      expect(data.name).to eq(midnight_sun.name)
      expect(data.date_release).to eq(midnight_sun.date_release.strftime('%Y-%m-%d'))
      expect(data.legacy_code).to eq(midnight_sun.legacy_code)
      expect(data.card_cycle_id).to eq(midnight_sun.card_cycle_id)
      expect(data.card_set_type_id).to eq(midnight_sun.card_set_type_id)
      expect(data.released_by).to eq(midnight_sun.released_by)
      expect(data.size).to eq(midnight_sun.size)
      expect(data.first_printing_id).to eq(midnight_sun.first_printing_id)
      expect(data.updated_at).to eq(midnight_sun.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
    end
  end

  describe 'filtering' do
    let!(:core_set) { CardSet.find('core') }

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
    def check_included_for_id(object_id, include_type, resource_type, sideloaded_id)
      params[:filter] = { id: { eq: object_id } }
      params[:include] = include_type
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(sideloaded_id)
    end

    describe 'include card cycle' do
      let!(:parhelion) { CardSet.find('parhelion') }
      let!(:borealis) { CardCycle.find('borealis') }

      it 'works' do
        check_included_for_id(parhelion.id, 'card_cycle', 'card_cycles', borealis.id)
      end
    end

    describe 'include card set type' do
      let!(:core) { CardSet.find('core') }
      let!(:core_set_type) { CardSetType.find('core') }

      it 'works' do
        check_included_for_id(core.id, 'card_set_type', 'card_set_types', core_set_type.id)
      end
    end

    describe 'include cards' do
      let!(:borealis) { CardSet.find('core') }
      let!(:legwork) { Card.find('legwork') }

      it 'works' do
        check_included_for_id(borealis.id, 'cards', 'cards', legwork.id)
      end
    end

    describe 'include printings' do
      let!(:midnight_sun) { CardSet.find('midnight_sun') }
      let!(:steelskin) { Printing.find('21166') }

      it 'works' do
        check_included_for_id(midnight_sun.id, 'printings', 'printings', steelskin.id)
      end
    end
  end
end
