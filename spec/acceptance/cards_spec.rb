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
    let(:query) { 'gamble' }
    example_request "Filter - Card Search Operator" do
      # TODO(plural): Enforce sort order by type and primary field name.
      explanation <<-EOM
Note: The search syntax is the same between the `Card` and `Printing` endpoints aside from some fields that only exist in one or the other. 

* A search query is a series of one or more conditions separated by one or more spaces (which acts as an implicit `and`) or explicit conjuctions (`and` and `or`):
  * `condition1 condition2 condition3` – gets all cards that meet the requirements of all three conditions
* Multiple values for a given term can be provided with `|` ( acts as `or`) or `&`. 
  * `text:"Runner is tagged"&meat` will return all cards with both `Runner is tagged` and `meat` in their text. 
  * `text:"Runner is tagged"|meat` will return all cards with either `Runner is tagged` or `meat` in their text.
* Each condition must be some or all of the name of a card or a criteria search:
  * `Street` – gets all cards with "Street" in their name
  * `x:credit` – gets all cards with "credit" in their ability text (see below for the full list of accepted criteria)
* Note that conditions containing spaces must be surrounded with quotation marks:
  * `"Street Magic"` or `x:"take all credits"`
* Negation operators
  * In addition to using a match or negated match operator (like `faction!anarch`), you can preface any condition with `!` or `-` to negate the whole condition.
  * `f:adam -card_type:resource` will return all non-resource Adam cards.
  * `f:apex !card_type:event` will return all non-event Apex cards.
* Conjunctions and grouping
  * Explicit `and` and `or` conjunctions are supported by the Search Syntax.
    * `t:identity and f:criminal` will return all Criminal Identities.
  * Explicit parenthesis will control grouping.
    * `(f:criminal or f:shaper) and t:identity` or `(f:criminal or f:shaper) t:identity` will return all Criminal or Shaper Identities.
  * A literal `and` or one using a space will have a higher precedence than an `or`.
    * `f:criminal or f:shaper and t:identity` and `f:criminal or f:shaper t:identity` will return all Criminal cards and Shaper Identities.

There are 4 types of fields in the Search Filter:

* **Array** - supports the `:` (an element in the array is an exact match) and `!` (an element in the array is not an exact match) operators.
  * `card_pool_ids:eternal|snapshot` returns all cards in the eternal or snapshot card pools. 
  * `card_pool!snapshot` returns all cards not in the snapshot card pool.
* **Boolean** - supports the `:` (match) and `!` (negated match) operators.  `true`, `false`, `t`, `f`, `1`, and `0` are all acceptable values.
  * `advanceable:true`, `advanceable:t`, and `advanceable:1` will all return all results where advanceable is true.
* **Integer** - supports the `:` (match),  `!` (negated match), `<`, `<=`, `>`, and `>=` operators.  Requires simple integer input.
  * For cards that have an X value, you can match with X, like `cost:X` (case insensitive).  an X value is treated as -1 behind the scenes.
* **String** - supports the `:` (LIKE) and `!` (NOT LIKE) operators. Input is transformed to lower case and the `%` decorations are added automatically, turning a query like `title:street` into a SQL fragment like `LOWER(stripped_title) LIKE '%street%`.
  * `title:clearance` returns everything with clearance in the title.
  * `title!clearance` returns everything without clearance in the title.

### Fields and their types
#{fields.join("\n")}
      EOM

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
