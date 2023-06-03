module API
  module V3
    module Private
      class Api::V3::Private::DecksController < JSONAPI::ResourceController
        include JwtAuthorizationConcern

        def context
          {current_user: @current_user}
        end
      end
    end
  end
end
