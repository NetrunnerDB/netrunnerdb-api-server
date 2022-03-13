module API
  module V3
    module Public
      class Api::V3::Public::CardResource < JSONAPI::Resource
        attributes :stripped_title, :title, :card_type_id, :side_id, :faction_id, :advancement_requirement, :agenda_points, :base_link, :cost, :deck_limit, :influence_cost, :influence_limit, :memory_cost, :minimum_deck_size, :strength, :stripped_text, :text, :trash_cost, :is_unique, :display_subtypes, :updated_at
        key_type :string

        has_one :card_type
        has_one :faction
        has_one :side
        has_many :subtypes
        has_many :printings
      end
    end
  end
end
