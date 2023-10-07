module API
    module V3
      module Public
        # Set default caching behavior for public resources.
        class Api::V3::Public::PublicController < ApplicationController
            include JSONAPI::ActsAsResourceController
            def index_related_resources
                expires_in 1.hour
                super
            end
            def index
                expires_in 1.hour
                super
            end
            def show
                expires_in 1.hour
                super
            end
            def show_relationship
                expires_in 1.hour
                super
            end
        end
    end
end
end
