module API
  module V3
    module Public
      class Api::V3::Public::MwlCardResource < JSONAPI::Resource
        attributes :global_penalty, :universal_faction_cost, :is_restricted, :is_banned, :points, :updated_at
        key_type :string

        paginator :none
      end
    end
  end
end
