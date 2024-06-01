require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Factions" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/factions" do
    example_request "All Factions" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'weyland_consortium' }
    example_request "Get A Single Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions?filter[side_id]=:side_id" do
    parameter :side_id, type: :string, required: true

    let(:side_id) { 'runner' }
    example_request "Filter - Get Factions for a single Side" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/factions?filter[is_mini]=:is_mini" do
    parameter :is_mini, type: :boolean, required: true

    let(:is_mini) { true }
    example_request "Filter - Get Mini Factions" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/sides/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'runner' }
    example_request "Relationship - Get Side for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards?filter[faction_id]=:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'neutral_runner' }
    example_request "Relationship - Get Cards for a Faction" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings?filter[faction_id]=:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'neutral_corp' }
    example_request "Relationship - Get Printings for a Faction" do
      expect(status).to eq 200
    end
  end
end
