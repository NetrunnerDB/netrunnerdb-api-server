module API
  module V3
    module Public
      class Api::V3::Public::RulingResource < JSONAPI::Resource
        immutable

        attributes :card_id, :ruling_source_id, :question, :answer, :text_ruling, :updated_at

        paginator :none

        has_one :card
        # has_many :rulings
        # has_many :cards, relation_name: :unified_cards
        # has_many :printings, relation_name: :unified_printings

        filters :card_id, :ruling_source_id
      end
    end
  end
end
