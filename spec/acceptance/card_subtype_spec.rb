require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Subtypes" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_subtypes" do
    example_request "All Card Subtypes" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_subtypes/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'code_gate' }
    example_request "Get A Single Card Subtype" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_subtypes/:id/relationships/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'advertisement' }
    example_request "Relationship - Get Card IDs for a Card Subtype" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_subtypes/:id/cards" do
    parameter :id, type: :string, required: true

    let(:id) { 'advertisement' }
    example_request "Relationship - Get Cards for a Card Subtype" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_subtypes/:id/relationships/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'advertisement' }
    example_request "Relationship - Get Printing IDs for a Card Subtype" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_subtypes/:id/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'advertisement' }
    example_request "Relationship - Get Printings for a Card Subtype" do
      expect(status).to eq 200
    end
  end
end
