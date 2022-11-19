require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Illustrators" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/illustrators" do
    example_request "All Illustrators" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/illustrators/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'ann_illustrator' }
    example_request "Get A Single Illustrator" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/illustrators/:id/relationships/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'tom_of_netrunner' }
    example_request "Relationship - Get Printing IDs for an Illustrator" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/illustrators/:id/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'tom_of_netrunner' }
    example_request "Relationship - Get Printings for an Illustrator" do
      expect(status).to eq 200
    end
  end
end
