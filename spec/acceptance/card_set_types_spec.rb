# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Card Set Types' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~EXPLANATION
    ## Relationships

    Card Set Type resources have the following relationships for their records.

    * Card Sets
  EXPLANATION

  get '/api/v3/public/card_set_types' do
    example_request 'All Card Set Types' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/card_set_types/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'core' }
    example_request 'Get A Single Card Set Type' do
      expect(status).to eq 200
    end
  end
end
