module API
  module V3
    module Public
      class Api::V3::Public::RulingResource < JSONAPI::Resource
        immutable

        attributes :card_id, :ruling_source_id, :question, :answer, :text_ruling, :updated_at

        paginator :none

        has_one :ruling_source
        has_one :card, relation_name: :unified_card

        filters :card_id, :ruling_source_id
      end
    end
  end
end
