require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Pools" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_pools" do
    example_request "All Card Pools" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_02' }
    example_request "Get A Single Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/relationships/format" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Format ID for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/format" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Format for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/relationships/card_cycles" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_01' }
    example_request "Relationship - Get Card Cycle IDs for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/card_cycles" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_01' }
    example_request "Relationship - Get Card Cycles for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/relationships/card_sets" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Card Set IDs for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/card_sets" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Card Sets for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/relationships/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Card IDs for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Cards for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/relationships/snapshots" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_01' }
    example_request "Relationship - Get Snapshot IDs for a Card Pool" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_pools/:id/snapshots" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_01' }
    example_request "Relationship - Get Snapshots for a Card Pool" do
      expect(status).to eq 200
    end
  end
end
