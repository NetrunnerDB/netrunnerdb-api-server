require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Factions" do
  fixtures :all
  Scenic.database.refresh_materialized_view(:unified_restrictions, concurrently: false, cascade: false)
  Scenic.database.refresh_materialized_view(:unified_cards, concurrently: false, cascade: false)
  Scenic.database.refresh_materialized_view(:unified_printings, concurrently: false, cascade: false)

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

  get "/api/v3/public/factions?filter[side_id]=:side_id" do
    route_summary 'Filter - Side'
    parameter :side_id, type: :string, required: true

    let(:side_id) { 'runner' }
    example_request "Filter - Get Factions for a single Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions?filter[is_mini]=:is_mini" do
    route_summary 'Filter - Mini Factions'
    parameter :is_mini, type: :boolean, required: true

    let(:is_mini) { true }
    example_request "Filter - Get Mini Factions" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/relationships/side" do
    route_summary "Retrieve Side ID for a faction"
    parameter :id, type: :string, required: true

    let(:id) { 'weyland_consortium' }
    example_request "Relationship - Get Side ID for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/side" do
    route_summary "Retrieve Side for a Faction"
    parameter :id, type: :string, required: true

    let(:id) { 'weyland_consortium' }
    example_request "Relationship - Get Side for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/relationships/cards" do
    route_summary "Retrieve Card Ids for a Faction"

    parameter :id, type: :string, required: true

    let(:id) { 'neutral_runner' }
    example_request "Relationship - Get Card Ids for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/cards" do
    route_summary "Retrieve Cards for a Faction"

    parameter :id, type: :string, required: true

    let(:id) { 'neutral_runner' }
    example_request "Relationship - Get Cards for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/relationships/printings" do
    route_summary "Retrieve Printing Ids for a Faction"

    parameter :id, type: :string, required: true

    let(:id) { 'neutral_corp' }
    example_request "Relationship - Get Printing Ids for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id/printings" do
    route_summary "Retrieve Printings for a Faction"

    parameter :id, type: :string, required: true

    let(:id) { 'neutral_corp' }
    example_request "Relationship - Get Printings for a Faction" do
      expect(status).to eq 200
    end
  end
end
