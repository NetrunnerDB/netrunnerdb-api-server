# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Reviews' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnderdb.com'

  explanation <<~EXPLANATION
    Card reviews have the following relationships

    * Card
  EXPLANATION

  get '/api/v3/public/reviews' do
    example_request 'All Reviews' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/reviews/:id' do
    parameter :id, type: :string, required: true

    let(:id) { '1' }
    example_request 'Get A Single Review' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/reviews?filter[card_id]=:query' do
    parameter :query, type: :string, required: true

    let(:query) { 'endurance' }
    example_request 'Filter on a single card id' do
      expect(status).to eq 200
    end
  end
end
