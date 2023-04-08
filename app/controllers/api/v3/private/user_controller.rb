module API
  module V3
    module Private
      class Api::V3::Private::UserController < ::ApplicationController
        include JwtAuthorizationConcern

        def index
          render json: { username: @current_user.id }
        end
      end
    end
  end
end
