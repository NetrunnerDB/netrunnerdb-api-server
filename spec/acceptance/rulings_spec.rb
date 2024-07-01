# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Rulings' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~HEREDOC
    ## Relationships

    Ruling resources have the following relationships for their records.

    * Card
  HEREDOC

  get '/api/v3/public/rulings' do
    example_request 'All Rulings' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/rulings?filter[card_id]=:card_id' do
    parameter :card_id, type: :string, required: true

    let(:card_id) { 'hedge_fund' }
    example_request 'Filter - Get Rulings for a single Card' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/rulings?filter[nsg_rules_team_verified]=:nsg_rules_team_verified' do
    parameter :nsg_rules_team_verified, type: :boolean, required: true

    let(:nsg_rules_team_verified) { true }
    example_request 'Filter - Get NSG Rules Team Verified Rulings' do
      expect(status).to eq 200
    end
  end
end
