module API
  module V3
    module Public
      class Api::V3::Public::CardCycleResource < JSONAPI::Resource
        caching
        immutable

        attributes :name, :date_release, :legacy_code, :card_set_ids, :first_printing_id, :released_by, :updated_at
        key_type :string

        has_many :card_sets
        has_many :cards, relation_name: :unified_cards
        has_many :printings, relation_name: :unified_printings

        paginator :none

        filters :date_release, :legacy_code, :released_by

        def first_printing_id
          UnifiedPrinting.where(card_cycle_id: @model.id).minimum(:id)
        end
      end
    end
  end
end
