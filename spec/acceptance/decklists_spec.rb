# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Decklists' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~EXPLANATION
    Decklists are published decks from users.

    ## Relationships

    Decklist resources have the following relationships for their records.

    * Side
    * Faction
    * Cards

  EXPLANATION

  get '/api/v3/public/decklists' do
    example_request 'All Decklists' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/decklists?filter[identity_card_id]=:card_id' do
    parameter :card_id, type: :string, required: true

    let(:card_id) { 'asa_group_security_through_vigilance' }
    example_request 'Filter - Get decklists with a particular Identity' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/decklists?filter[card_id]=pennyshaver,stargate' do
    parameter :card_id, type: :string, required: true

    example_request 'Filter - Get decklists containing all supplied Card ids' do
      explanation <<~EXPLANATION
        The card_id filter can accept a single card_id or a comma-separated list of card ids.

        If multiple card ids are supplied, the decklist must contain all of the
        cards to be included in the results.
      EXPLANATION

      expect(status).to eq 200
    end
  end

  get '/api/v3/public/decklists?filter[exclude_card_id]=pennyshaver,stargate' do
    parameter :exclude_card_id, type: :string, required: true

    example_request 'Filter - Get decklists excluding all supplied Card ids' do
      explanation <<~EXPLANATION
        The exclude_card_id filter can accept a single card_id or a comma-separated list of card ids.

        If multiple card ids are supplied, the decklist must NOT contain any of the
        cards to be included in the results.
      EXPLANATION

      expect(status).to eq 200
    end
  end

  get '/api/v3/public/decklists?filter[faction_id]=:faction_id' do
    parameter :nsg_rules_team_verified, type: :boolean, required: true

    let(:faction_id) { 'haas_bioroid' }
    example_request 'Filter - Get Decklists for a given faction' do
      expect(status).to eq 200
    end
  end
end
