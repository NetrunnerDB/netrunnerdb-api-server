require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Sets" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_sets" do
    example_request "All Card Sets" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id" do
    route_summary 'Retrieve a single Card Set by ID'
    parameter :id, type: :string, required: true

    let(:id) { 'midnight_sun' }
    example_request "Get A Single Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets?filter[card_cycle_id]=:card_cycle_id" do
    route_summary 'Filter - Card Cycle ID'
    parameter :card_cycle_id, type: :string, required: true

    let(:side_id) { 'borealis' }
    example_request "Filter - Get Card Sets filtered to a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets?filter[card_set_type_id]=:card_set_type_id" do
    route_summary 'Filter - Card Set Type ID'
    parameter :card_set_type_id, type: :string, required: true

    let(:side_id) { 'core' }
    example_request "Filter - Get Card Sets filtered to a Card Set Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/relationships/card_cycle" do
    route_summary "Retrieve Card Cycle ID for a Card Set"
    parameter :id, type: :string, required: true

    let(:id) { 'parhelion' }
    example_request "Relationship - Get Card Cycle ID for a Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/card_cycle" do
    route_summary "Retrieve Card Cycle for a Card Set"
    parameter :id, type: :string, required: true

    let(:id) { 'parhelion' }
    example_request "Relationship - Get Card Cycle for a Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/relationships/card_set_type" do
    route_summary "Retrieve Card Set Type ID for a Card Set"
    parameter :id, type: :string, required: true

    let(:id) { 'midnight_sun' }
    example_request "Relationship - Get Card Set ID for a Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/card_set_type" do
    route_summary "Retrieve Card Set Type for a Card Set"
    parameter :id, type: :string, required: true

    let(:id) { 'midnight_sun' }
    example_request "Relationship - Get Card Set Type for a Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/relationships/cards" do
    route_summary "Retrieve Card IDs for a Card Set"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Card IDs for a Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/cards" do
    route_summary "Retrieve Cards for a Card Set"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Cards for a Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/relationships/printings" do
    route_summary "Retrieve Printing IDs for a Card Set"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Printing IDs for a Card Set" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_sets/:id/printings" do
    route_summary "Retrieve Printings for a Card Set"

    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Printings for a Card Set" do
      expect(status).to eq 200
    end
  end
end
