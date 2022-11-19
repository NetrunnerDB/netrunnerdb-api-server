require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Cycles" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_cycles" do
    example_request "All Card Cycles" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'borealis' }
    example_request "Get A Single Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/relationships/card_sets" do
    parameter :id, type: :string, required: true

    let(:id) { 'borealis' }
    example_request "Relationship - Get Card Set IDs for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/card_sets" do
    parameter :id, type: :string, required: true

    let(:id) { 'borealis' }
    example_request "Relationship - Get Card Sets for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/relationships/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Card IDs for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Cards for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/relationships/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Printing IDs for a Card Cycle" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_cycles/:id/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Relationship - Get Printings for a Card Cycle" do
      expect(status).to eq 200
    end
  end
end
