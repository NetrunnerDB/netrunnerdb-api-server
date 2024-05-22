module API
  module V3
    module Public
      class Api::V3::Public::RulingResource < JSONAPI::Resource
        caching
        immutable

        attributes :card_id, :nsg_rules_team_verified
        attributes :question, :answer, :text_ruling, :updated_at

        paginator :none

        has_one :card, relation_name: :unified_card

        filters :card_id, :nsg_rules_team_verified
      end
    end
  end
end
