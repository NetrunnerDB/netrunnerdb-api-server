require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Factions" do

  fixtures :factions

  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/factions" do
    example_request "All Factions" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id" do
    route_summary 'Retrieve a single Faction by ID'
    parameter :id, type: :string, required: true

    let(:id) { 'weyland_consortium' }
    example_request "Get A Single Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions?filter[is_mini]=true" do
    route_summary 'Only Mini Factions'
    route_description 'is_mini is a filter that allows you to include or exclude Mini Factions'

    example_request "Get Mini Factions" do
      expect(status).to eq 200
    end
  end
end
