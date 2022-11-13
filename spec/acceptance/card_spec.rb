require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Cards" do
  fixtures :all
  Scenic.database.refresh_materialized_view(:unified_restrictions, concurrently: false, cascade: false)
  Scenic.database.refresh_materialized_view(:unified_cards, concurrently: false, cascade: false)
  Scenic.database.refresh_materialized_view(:unified_printings, concurrently: false, cascade: false)

  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/cards" do
    example_request "All Cards" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id" do
    route_summary 'Retrieve a single Card by ID'
    parameter :id, type: :string, required: true

    let(:id) { 'hedge_fund' }
    example_request "Get A Single Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/side" do
    route_summary "Retrieve Side ID for a card"
    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Side ID for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/side" do
    route_summary "Retrieve Side for a Card"
    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Side for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/faction" do
    route_summary "Retrieve Faction ID for a Card"
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Faction ID for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/faction" do
    route_summary "Retrieve Faction for a Card"
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Faction for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/card_type" do
    route_summary "Retrieve Card Type ID for a Card"
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Card Type ID for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/card_type" do
    route_summary "Retrieve Card Type for a Card"
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Card Type for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/card_subtypes" do
    route_summary "Retrieve Card Subtype IDs for a Card"

    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Card Subtype IDs for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/card_subtypes" do
    route_summary "Retrieve Card Subtypes for a Card"

    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Card Subtypes for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/printings" do
    route_summary "Retrieve Printing IDs for a Card"

    parameter :id, type: :string, required: true

    let(:id) { 'sure_gamble' }
    example_request "Relationship - Get Printing IDs for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/printings" do
    route_summary "Retrieve Printings for a Card"

    parameter :id, type: :string, required: true

    let(:id) { 'sure_gamble' }
    example_request "Relationship - Get Printings for a Card" do
      expect(status).to eq 200
    end
  end
end
