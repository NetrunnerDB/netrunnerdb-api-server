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

    fields = CardSearchQueryBuilder.fields.map {|x| "* **%s**: Type: %s%s" % [x.keywords.join(', '), x.type.to_s, x.documentation.nil? ? '' : "\n  * %s" % x.documentation]}
    # TODO(plural): Enforce sort order by type and primary field name.
    explanation <<-EOM
### Card Search Syntax

There are 4 types of fields in the Search Filter:

* **Array** - supports the `:` (an element in the array is an exact match) and `!` (an element in the array is not an exact match) operators.
* **Boolean** - supports the `:` (match) and `!` (negated match) operators.  `true`, `false`, `t`, `f``, `1`', and `0`` are all acceptable values.
* **Integer** - supports the `:` (match),  `!` (negated match), `<`, `<=`, `>`, and `>=` operators.  Requires simple integer input.
* **String** - supports the `:` (LIKE) and `!` (NOT LIKE) operators. Input is transformed to lower case and the `%` decorations are added automatically, turning a query like `title:street` into a SQL fragment like `LOWER(stripped_title) LIKE '%street%`.

#### Fields and their types
#{fields.join("\n")}
    EOM

    let(:query) { 'gamble' }
    example_request "Filter - Card Search Operator" do
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
end
