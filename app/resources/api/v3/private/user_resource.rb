module API
    module V3
      module Private
        class Api::V3::Private::UserResource < JSONAPI::Resource
          immutable

          key_type :string

          paginator :none

          exclude_links :default
        end
      end
    end
  end
