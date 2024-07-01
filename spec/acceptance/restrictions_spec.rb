# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Restrictions' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~HEREDOC
    ## Relationships

    Restriction resources have the following relationships for their records.

    * Format
  HEREDOC

  get '/api/v3/public/restrictions' do
    example_request 'All Restrictions' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/restrictions/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'standard_banlist' }
    example_request 'Get A Single Restriction' do
      expect(status).to eq 200
    end
  end
end
