# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Card Cycles' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~HEREDOC
    ## Relationships

    Card Cycle resources have the following relationships for their records.

    * Card Sets
    * Cards
    * Printings
  HEREDOC

  get '/api/v3/public/card_cycles' do
    example_request 'All Card Cycles' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/card_cycles/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'borealis' }
    example_request 'Get A Single Card Cycle' do
      expect(status).to eq 200
    end
  end
end
