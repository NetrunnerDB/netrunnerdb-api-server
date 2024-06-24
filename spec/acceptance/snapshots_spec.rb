# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Snapshots' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  explanation <<~HEREDOC
    ## Relationships

    Snapshot resources have the following relationships for their records.

    * Card Pool
    * Format
    * Restriction
  HEREDOC

  get '/api/v3/public/snapshots' do
    example_request 'All Snapshots' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/snapshots/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'startup_02' }
    example_request 'Get A Single Snapshot' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/snapshots?filter[active]=:active' do
    parameter :card_cycle_id, type: :string, required: true

    let(:active) { 'true' }
    example_request 'Filter - Get Snapshots filtered by Active Status' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/snapshots?filter[format_id]=:format_id' do
    parameter :card_cycle_id, type: :string, required: true

    let(:format_id) { 'startup' }
    example_request 'Filter - Get Snapshots filtered by Format Id' do
      expect(status).to eq 200
    end
  end
end
