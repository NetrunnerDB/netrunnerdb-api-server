require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Printings" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/printings" do
    example_request "All Printings" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id" do
    route_summary 'Retrieve a single Printing by ID'
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Get A Single Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/card" do
    route_summary "Retrieve Card ID for a Printing"
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Card ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/card" do
    route_summary "Retrieve Card for a Printing"
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Card for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/card_cycle" do
    route_summary "Retrieve Card Cycle ID for a card"
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Cycle ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/card_cycle" do
    route_summary "Retrieve Card cycle for a Printing"
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Cycle for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/card_set" do
    route_summary "Retrieve Card Set ID for a Printing"
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Set ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/card_set" do
    route_summary "Retrieve Card Set for a Printing"
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Set for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/faction" do
    route_summary "Retrieve Faction ID for a Printing"

    parameter :id, type: :string, required: true

    let(:id) { '01110' }
    example_request "Relationship - Get Faction ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/faction" do
    route_summary "Retrieve Faction for a Printing"

    parameter :id, type: :string, required: true

    let(:id) { '01110' }
    example_request "Relationship - Get Faction for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/illustrators" do
    route_summary "Retrieve Illustrator IDs for a Printing"

    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Illustrator IDs for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/illustrators" do
    route_summary "Retrieve Illustrators for a Printing"

    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Illustrators for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/side" do
    route_summary "Retrieve Side ID for a Printing"
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Side ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/side" do
    route_summary "Retrieve Side for a Printing"
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Side for a Printing" do
      expect(status).to eq 200
    end
  end

end
