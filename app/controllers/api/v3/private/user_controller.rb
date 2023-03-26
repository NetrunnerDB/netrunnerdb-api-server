module API
  module V3
    module Private
      class Api::V3::Private::UserController < ::ApplicationController
        include JwtAuthorizationConcern

        def index
          render json: { username: @auth_token_payload['preferred_username'] }
        end
      end
    end
  end
end
