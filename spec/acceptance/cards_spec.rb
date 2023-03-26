require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Cards" do
  header "Content-Type", "application/json"
  header "Host", "api-preview.netrunnerdb.com"

  get "/api/v3/public/cards" do
    example_request "All Cards" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id" do
    parameter :id, type: :string, required: true

    let(:id) { 'hedge_fund' }
    example_request "Get A Single Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards?filter[search]=:query" do
    parameter :query, type: :string, required: true

    # TODO(plural): Enforce sort order by type and primary field name.
    fields = CardSearchQueryBuilder.fields.map {|x| "* **%s**: Type: %s%s" % [x.keywords.join(', '), x.type.to_s, x.documentation.nil? ? '' : "\n  * %s" % x.documentation]}
    let(:query) { 'gamble' }
    example_request "Filter - Card Search Operator" do
      explanation "%s\n### Fields and their types\n%s" % [SearchQueryBuilder.search_filter_docs, fields.join("\n")]

      expect(status).to eq 200
    end
  end


  get "/api/v3/public/cards/:id/relationships/side" do
    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Side ID for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/side" do
    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Side for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/faction" do
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Faction ID for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/faction" do
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Faction for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/card_type" do
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Card Type ID for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/card_type" do
    parameter :id, type: :string, required: true

    let(:id) { 'prisec' }
    example_request "Relationship - Get Card Type for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/card_subtypes" do
    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Card Subtype IDs for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/card_subtypes" do
    parameter :id, type: :string, required: true

    let(:id) { 'adonis_campaign' }
    example_request "Relationship - Get Card Subtypes for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'sure_gamble' }
    example_request "Relationship - Get Printing IDs for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/printings" do
    parameter :id, type: :string, required: true

    let(:id) { 'sure_gamble' }
    example_request "Relationship - Get Printings for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/relationships/rulings" do
    parameter :id, type: :string, required: true

    let(:id) { 'sure_gamble' }
    example_request "Relationship - Get Ruling IDs for a Card" do
      expect(status).to eq 200
    end
  end

  get "/api/v3/public/cards/:id/rulings" do
    parameter :id, type: :string, required: true

    let(:id) { 'sure_gamble' }
    example_request "Relationship - Get Rulings for a Card" do
      expect(status).to eq 200
    end
  end
end
