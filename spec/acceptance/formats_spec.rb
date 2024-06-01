# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Formats' do
  header 'Content-Type', 'application/json'
  header 'Host', 'api-preview.netrunnerdb.com'

  get '/api/v3/public/formats' do
    example_request 'All Formats' do
      expect(status).to eq 200
    end
  end

  get '/api/v3/public/formats/:id' do
    parameter :id, type: :string, required: true

    let(:id) { 'startup' }
    example_request 'Get A Single Format' do
      expect(status).to eq 200
    end
  end
end
