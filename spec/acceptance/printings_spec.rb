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
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Get A Single Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings?filter[search]=:query" do
    parameter :query, type: :string, required: true

    # TODO(plural): Enforce sort order by type and primary field name.
    fields = PrintingSearchQueryBuilder.fields.map {|x| "* **%s**: Type: %s%s" % [x.keywords.join(', '), x.type.to_s, x.documentation.nil? ? '' : "\n  * %s" % x.documentation]}
    let(:query) { 'flavor:boi' }
    example_request "Filter - Printing Search Operator" do
      explanation "%s\n### Fields and their types\n%s" % [SearchQueryBuilder.search_filter_docs, fields.join("\n")]

      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/card" do
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Card ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/card" do
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Card for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/card_cycle" do
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Cycle ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/card_cycle" do
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Cycle for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/card_set" do
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Set ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/card_set" do
    parameter :id, type: :string, required: true

    let(:id) { '01050' }
    example_request "Relationship - Get Card Set for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/faction" do
    parameter :id, type: :string, required: true

    let(:id) { '01110' }
    example_request "Relationship - Get Faction ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/faction" do
    parameter :id, type: :string, required: true

    let(:id) { '01110' }
    example_request "Relationship - Get Faction for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/illustrators" do
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Illustrator IDs for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/illustrators" do
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Illustrators for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/relationships/side" do
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Side ID for a Printing" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/printings/:id/side" do
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request "Relationship - Get Side for a Printing" do
      expect(status).to eq 200
    end
  end

end
