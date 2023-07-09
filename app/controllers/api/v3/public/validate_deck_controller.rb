module API
    module V3
      module Public
        class Api::V3::Public::ValidateDeckController < ::ApplicationController
          def index
            out = params[:data]

            if out.nil? or not (out.has_key?(:attributes) and out[:attributes].has_key?(:identity_card_id) and out[:attributes].has_key?(:side_id) and out[:attributes].has_key?(:cards))
              return render json: {
                :errors => [{
                  :title => "Invalid request",
                  :detail => "Valid requests must be of the form `{'data': { 'attributes': { 'identity_card_id': 'foo', 'side_id': 'bar', 'cards': { } } }
}`. Extra fields are allowed.",
                  :code => "400",
                  :status => "400"
                }]}, :status => :bad_request
            end

            deck = {
              'identity_card_id' => params[:data][:attributes][:identity_card_id],
              'side_id' => params[:data][:attributes][:side_id],
              'cards' => {}
            }
            params[:data][:attributes][:cards].each {|c,q| deck['cards'][c] = q}

            v = DeckValidator.new(deck)

            out[:attributes][:is_valid] = v.is_valid?
            out[:attributes][:errors] = v.errors
            render json: { data: out }
          end
        end
      end
    end
  end
