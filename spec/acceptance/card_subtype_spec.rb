# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Card Subtypes' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~EXPLANATION
    ## Relationships

    Card Subtype resources have the following relationships for their records.

    * Cards
    * Printings
  EXPLANATION

  get '/api/v3/public/card_subtypes' do
    example_request 'All Card Subtypes' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/card_subtypes/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'code_gate' }
    example_request 'Get A Single Card Subtype' do
      expect(status).to eq 200
    end
  end
end
