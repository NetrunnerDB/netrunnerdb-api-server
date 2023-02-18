require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Formats" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/formats" do
    example_request "All Formats" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/formats/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup' }
    example_request "Get A Single Format" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/formats/:id/relationships/card_pools" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard' }
    example_request "Relationship - Get Card Pool IDs for a Format" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/formats/:id/card_pools" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup' }
    example_request "Relationship - Get Card Pools for a Format" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/formats/:id/relationships/restrictions" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard' }
    example_request "Relationship - Get Restriction IDs for a Format" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/formats/:id/restrictions" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard' }
    example_request "Relationship - Get Restrictions for a Format" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/formats/:id/relationships/restrictions" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard' }
    example_request "Relationship - Get Snapshot IDs for a Format" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/formats/:id/snapshots" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup' }
    example_request "Relationship - Get Snapshots for a Format" do
      expect(status).to eq 200
    end
  end
end
