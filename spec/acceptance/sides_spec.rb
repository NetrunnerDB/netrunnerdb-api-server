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
    parameter :id, type: :string, required: true

    let(:id) { 'runner' }
    example_request "Get A Single side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_types?filter[side_id]=:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Card Types for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions?filter[side_id]=:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'runner' }
    example_request "Relationship - Get Factions for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards?filter[side_id]=:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Cards for a Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings?filter[side_id]=:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'corp' }
    example_request "Relationship - Get Printings for a Side" do
      expect(status).to eq 200
    end
  end
end
