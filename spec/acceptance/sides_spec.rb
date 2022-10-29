require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Sides" do

  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/sides" do
    example_request "All Sides" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id" do
    route_summary 'Retrieve a single Side by ID'
    parameter :id, type: :string, required: true

    let(:id) { 'runner' }
    example_request "Get A Single side" do
      expect(status).to eq 200
    end
  end
end
