module API
  module V3
    module Public
      class Api::V3::Public::CardSetResource < JSONAPI::Resource
        immutable

        attributes :name, :date_release, :size, :card_cycle_id, :card_set_type_id, :legacy_code, :first_printing_id, :updated_at
        key_type :string

        paginator :none

        has_one :card_cycle
        has_one :card_set_type
        has_many :printings, relation_name: :unified_printings
        has_many :cards, relation_name: :unified_cards

        filters :card_cycle_id, :card_set_type_id

        def first_printing_id
          first_printing = @model.printings.find_by(position_in_set: 1)
          return if first_printing.nil?
          first_printing.id
        end
      end
    end
  end
end
