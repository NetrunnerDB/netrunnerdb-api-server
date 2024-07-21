# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Cards' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~EXPLANATION
    ## Relationships

    Card resources have the following relationships for their records.

    * Card Cycles
    * Card Sets
    * Card Subtypes (if not present, the relationship link will filter for a 'none' value and return an empty set)
    * Card Type
    * Decklists
    * Faction
    * Printings
    * Rulings
    * Side
  EXPLANATION

  get '/api/v3/public/cards' do
    example_request 'All Cards' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/cards/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'hedge_fund' }
    example_request 'Get A Single Card' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/cards?filter[search]=:query' do
    parameter :query, type: :string, required: true

    # TODO(plural): Enforce sort order by type and primary field name.
    fields = CardSearchQueryBuilder.fields.map do |x|
      format('* **%<keywords>s**: Type: %<type>s%<documentation>s',
             keywords: x.keywords.join(', '),
             type: x.type.to_s,
             documentation: x.documentation.nil? ? '' : "\n  * #{x.documentation}")
    end
    let(:query) { 'gamble' }
    example_request 'Filter - Card Search Operator' do
      explanation format("%<docs>s\n### Fields and their types\n%<fields>s",
                         docs: SearchQueryBuilder.search_filter_docs, fields: fields.join("\n"))

      expect(status).to eq 200
    end
  end
end
