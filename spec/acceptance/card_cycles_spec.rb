require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Cycles" do
  fixtures :all
  Scenic.database.refresh_materialized_view(:unified_restrictions, concurrently: false, cascade: false)
  Scenic.database.refresh_materialized_view(:unified_cards, concurrently: false, cascade: false)
  Scenic.database.refresh_materialized_view(:unified_printings, concurrently: false, cascade: false)

  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_cycles" do
    example_request "All Card Cycles" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id" do
    route_summary 'Retrieve a single Card Cycle by ID'
    parameter :id, type: :string, required: true

    let(:id) { 'borealis' }
    example_request "Get A Single Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/relationships/card_sets" do
    route_summary "Retrieve Card Set IDs for a Card Cycle"
    parameter :id, type: :string, required: true

    let(:id) { 'borealis' }
    example_request "Relationship - Get Card Set IDs for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/card_sets" do
    route_summary "Retrieve Card Sets for a Card Cycle"
    parameter :id, type: :string, required: true

    let(:id) { 'borealis' }
    example_request "Relationship - Get Card Sets for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/relationships/cards" do
    route_summary "Retrieve Card IDs for a Card Cycle"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Card IDs for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/cards" do
    route_summary "Retrieve Cards for a Card Cycle"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Cards for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/relationships/printings" do
    route_summary "Retrieve Printing IDs for a Card Cycle"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Printing IDs for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/printings" do
    route_summary "Retrieve Printings for a Card Cycle"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Printings for a Card Cycle" do
      expect(status).to eq 200
    end
  end
end
