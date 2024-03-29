require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Snapshots" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/snapshots" do
    example_request "All Snapshots" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_02' }
    example_request "Get A Single Snapshot" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots?filter[active]=:active" do
    parameter :card_cycle_id, type: :string, required: true

    let(:active) { 'true' }
    example_request "Filter - Get Snapshots filtered by Active Status" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots?filter[format_id]=:format_id" do
    parameter :card_cycle_id, type: :string, required: true

    let(:format_id) { 'startup' }
    example_request "Filter - Get Snapshots filtered by Format Id" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots/:id/relationships/card_pool" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Card Pool ID for a Snapshot" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots/:id/card_pool" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Card Pool for a Snapshot" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots/:id/relationships/format" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Format ID for a Snapshot" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots/:id/format" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Format for a Snapshot" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots/:id/relationships/restriction" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Restriction ID for a Snapshot" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/snapshots/:id/restriction" do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_02' }
    example_request "Relationship - Get Restriction for a Snapshot" do
      expect(status).to eq 200
    end
  end
end
