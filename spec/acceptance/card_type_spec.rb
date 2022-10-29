require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Types" do
  fixtures :card_types

  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_types" do
    example_request "All Card Types" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types/:id" do
    route_summary 'Retrieve a single Card Type by ID'
    parameter :id, type: :string, required: true

    let(:id) { 'upgrade' }
    example_request "Get A Single Card Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types?filter[side_id]=runner" do
    route_summary 'Only Single Side Card Types'
    route_description 'side_id is a filter that allows you to include or exclude Card Types by Side'

    example_request "Get Runner Card Types" do
      expect(status).to eq 200
    end
  end
end
