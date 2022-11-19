require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Types" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_types" do
    example_request "All Card Types" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'upgrade' }
    example_request "Get A Single Card Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types?filter[side_id]=:side_id" do
    parameter :side_id, type: :string, required: true

    let(:side_id) { 'runner' }
    example_request "Filter - Get Card Types for a single Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types/:id/relationships/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'upgrade' }
    example_request "Relationship - Get Card IDs for a Card Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types/:id/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'upgrade' }
    example_request "Relationship - Get Cards for a Card Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types/:id/relationships/side" do
    parameter :id, type: :string, required: true

    let(:id) { 'upgrade' }
    example_request "Relationship - Get Side ID for a Card Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types/:id/side" do
    parameter :id, type: :string, required: true

    let(:id) { 'upgrade' }
    example_request "Relationship - Get Side for a Card Type" do
      expect(status).to eq 200
    end
  end
end
