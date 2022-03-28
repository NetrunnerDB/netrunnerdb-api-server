module API
  module V3
    module Public
      class Api::V3::Public::PrintingResource < JSONAPI::Resource
        attributes :card_id, :card_set_id, :printed_text, :printed_is_unique, :flavor, :illustrator, :position, :quantity, :date_release, :updated_at
        key_type :string

        has_one :card_cycle
        has_one :card_set
        has_one :side
        has_one :faction
        has_one :card
      end
    end
  end
end
