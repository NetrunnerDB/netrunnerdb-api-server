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

  get "/api/v3/public/sides/:id/relationships/card_types" do
    route_summary "Retrieve Card Type IDs for a side"
    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Card Type IDs for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id/card_types" do
    route_summary "Retrieve Card Types for a side"
    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Card Types for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id/relationships/factions" do
    route_summary "Retrieve Faction IDs for a side"
    parameter :id, type: :string, required: true

    let(:id) { 'runner' }
    example_request "Relationship - Get Faction IDs for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id/factions" do
    route_summary "Retrieve Factions for a side"
    parameter :id, type: :string, required: true

    let(:id) { 'runner' }
    example_request "Relationship - Get Factions for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id/relationships/cards" do
    route_summary "Retrieve Card IDs for a side"

    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Card IDs for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id/cards" do
    route_summary "Retrieve Cards for a side"

    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Cards for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id/relationships/printings" do
    route_summary "Retrieve Printing IDs for a Side"

    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Printing IDs for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id/printings" do
    route_summary "Retrieve Printings for a Side"

    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Printings for a Side" do
      expect(status).to eq 200
    end
  end
end
