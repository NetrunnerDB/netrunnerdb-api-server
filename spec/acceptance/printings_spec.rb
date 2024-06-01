# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Printings' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

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
      format('* **%s**: Type: %s%s', x.keywords.join(', '), x.type.to_s,
             x.documentation.nil? ? '' : "\n  * %s" % x.documentation)
    end
    let(:query) { 'flavor:boi' }
    example_request 'Filter - Printing Search Operator' do
      explanation format("%s\n### Fields and their types\n%s", SearchQueryBuilder.search_filter_docs, fields.join("\n"))

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
