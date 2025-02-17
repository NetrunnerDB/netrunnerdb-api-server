# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllustratorResource, type: :resource do
  describe 'serialization' do
    let!(:illustrator) { Illustrator.find('tom_of_netrunner') }

    it 'works' do
      params[:filter] = { id: { eq: illustrator.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(illustrator.id)
      expect(data.name).to eq(illustrator.name)
      expect(data.num_printings).to eq(illustrator.num_printings)
      expect(data.updated_at).to eq(illustrator.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('illustrators')
    end
  end

  describe 'filtering' do
    let!(:illustrator) { Illustrator.find('good_drawer') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: illustrator.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([illustrator.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(illustrator_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: illustrator_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(id)
    end

    describe 'include printings' do
      let!(:illustrator) { Illustrator.find('good_drawer') }
      let!(:printing) { Printing.find('12345') }

      it 'works' do
        check_included_for_id(illustrator.id, 'printings', 'printings', printing.id)
      end
    end
  end
end
