require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Card Set Types" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/card_set_types" do
    example_request "All Card Set Types" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_set_types/:id" do
    route_summary 'Retrieve a single Card Set Type by ID'
    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request "Get A Single Card Set Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_set_types/:id/relationships/card_sets" do
    route_summary "Retrieve Card Set IDs for a Card Set Type"
    parameter :id, type: :string, required: true

    let(:id) { 'booster_pack' }
    example_request "Relationship - Get Card Set IDs for a Card Set Type" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/card_set_types/:id/card_sets" do
    route_summary "Retrieve Card Sets for a Card Set Type"
    parameter :id, type: :string, required: true

    let(:id) { 'booster_pack' }
    example_request "Relationship - Get Card Sets for a Card Set Type" do
      expect(status).to eq 200
    end
  end
end
