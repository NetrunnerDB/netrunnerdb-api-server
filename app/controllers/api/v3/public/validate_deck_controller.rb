module API
  module V3
    module Public
      class Api::V3::Public::ValidateDeckController < ::ApplicationController
        def index
          out = params[:data]

          # Check for presence of everything needed to perform deck validation and error if not present.
          if out.nil? or not (
              out.has_key?(:attributes) and
              out[:attributes].has_key?(:identity_card_id) and
              out[:attributes].has_key?(:side_id) and
              out[:attributes].has_key?(:cards) and
              out[:attributes].has_key?(:validations))
            return render json: {
              :errors => [{
                :title => "Invalid request",
                :detail => "Valid requests must be of the form `{'data': { 'attributes': { 'identity_card_id': 'foo', 'side_id': 'bar', 'cards': { }, 'validations': [] } }}`. Extra fields are allowed.",
                :code => "400",
                :status => "400"
              }]}, :status => :bad_request
          end

          # Deck validation takes in a simple datastructure, so construct it instead of passing around ActionController::Parameters
          deck = {
            'identity_card_id' => params[:data][:attributes][:identity_card_id],
            'side_id' => params[:data][:attributes][:side_id],
            'cards' => {},
            'validations' => [],
          }
          params[:data][:attributes][:cards].each {|c,q| deck['cards'][c] = q}
          params[:data][:attributes][:validations].each do |v|
            deck['validations'] << v
          end

          v = DeckValidator.new(deck)

          out[:attributes][:is_valid] = v.is_valid?
          out[:attributes][:validation_errors] = v.errors
          out[:attributes][:validations] = v.validations

          render json: { data: out }, :status => :ok
        end
      end
    end
  end
end
