# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Printings' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~EXPLANATION
    ## Relationships

    Printing resources have the following relationships for their records.

    * Card
    * Card Cycle
    * Card Set
    * Card Subtypes
    * Card Type
    * Faction
    * Illustrators
    * Side
  EXPLANATION

  get '/api/v3/public/printings' do
    example_request 'All Printings' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/printings/:id' do
    parameter :id, type: :string, required: true

    let(:id) { '01056' }
    example_request 'Get A Single Printing' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/printings?filter[search]=:query' do
    parameter :query, type: :string, required: true

    # TODO(plural): Enforce sort order by type and primary field name.
    fields = PrintingSearchQueryBuilder.fields.map do |x|
      format('* **%<keywords>s**: Type: %<type>s%<documentation>s',
             keywords: x.keywords.join(', '),
             type: x.type.to_s,
             documentation: x.documentation.nil? ? '' : "\n  * #{x.documentation}")
    end
    let(:query) { 'flavor:boi' }
    example_request 'Filter - Printing Search Operator' do
      explanation format("%<docs>s\n### Fields and their types\n%<fields>s",
                         docs: SearchQueryBuilder.search_filter_docs, fields: fields.join("\n"))

      expect(status).to eq 200
    end
  end

  get '/api/v3/public/printings?filter[distinct_cards]=true' do
    example_request 'Filter - Distinct Cards' do
      explanation 'The distinct_cards filter will return only the latest printing of each card.'
      expect(status).to eq 200
    end
  end
end
