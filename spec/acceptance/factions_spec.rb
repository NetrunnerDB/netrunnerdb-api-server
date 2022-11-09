require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Factions" do
  fixtures :all

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

  get "/api/v3/public/factions/:id/relationships/side" do
    route_summary "Retrieve side for a faction"
    parameter :id, type: :string, required: true

    let(:id) { 'weyland_consortium' }
    example_request "Relationship - Get Side for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/relationships/cards" do
    route_summary "Retrieve Cards for a Faction"

    parameter :id, type: :string, required: true

    let(:id) { 'weyland_consortium' }
    example_request "Relationship - Get Cards for a Faction" do
      explanation "TODO(plural): Add Card Fixtures"
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/relationships/printings" do
    route_summary "Retrieve Printings for a Faction"

    parameter :id, type: :string, required: true

    let(:id) { 'adam' }
    example_request "Relationship - Get Printings for a Faction" do
      explanation "TODO(plural): Add Printing Fixtures"
      expect(status).to eq 200
    end
  end
end
