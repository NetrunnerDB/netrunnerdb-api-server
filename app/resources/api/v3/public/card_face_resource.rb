module API
  module V3
    module Public
      class Api::V3::Public::CardFaceResource < JSONAPI::Resource
        immutable

        attributes :stripped_title, :title, :advancement_requirement
        attributes :agenda_points, :base_link, :cost, :memory_cost, :strength
        attributes :stripped_text, :text, :trash_cost, :is_unique
        attributes :card_subtype_ids, :display_subtypes, :updated_at

        key_type :string

        def card_subtype_ids
          @model.card_subtypes.map { |s| s.id }
        end

        has_one :card
      end
    end
  end
end
