# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Card Sets' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  get '/api/v3/public/card_sets' do
    example_request 'All Card Sets' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/card_sets/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'midnight_sun' }
    example_request 'Get A Single Card Set' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/card_sets?filter[card_cycle_id]=:card_cycle_id' do
    parameter :card_cycle_id, type: :string, required: true

    let(:side_id) { 'borealis' }
    example_request 'Filter - Get Card Sets filtered to a Card Cycle' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/card_sets?filter[card_set_type_id]=:card_set_type_id' do
    parameter :card_set_type_id, type: :string, required: true

    let(:side_id) { 'core' }
    example_request 'Filter - Get Card Sets filtered to a Card Set Type' do
      expect(status).to eq 200
    end
  end
end
