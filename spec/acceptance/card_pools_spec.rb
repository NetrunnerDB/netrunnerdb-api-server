# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Card Pools' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~EXPLANATION
    ## Relationships

    Card Pool resources have the following relationships for their records.

    * Card Cycles
    * Card Sets
    * Cards
    * Format
    * Printings
    * Snapshots
  EXPLANATION

  get '/api/v3/public/card_pools' do
    example_request 'All Card Pools' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/card_pools/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_02' }
    example_request 'Get A Single Card Pool' do
      expect(status).to eq 200
    end
  end
end
