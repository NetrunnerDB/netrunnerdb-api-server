module API
  module V3
    module Public
      class Api::V3::Public::CardResource < JSONAPI::Resource
        # TODO(plural): get the relationships in here and possibly replace the keywords field.
        attributes :name, :card_type_id, :side_id, :faction_id, :advancement_requirement, :agenda_points, :base_link, :cost, :deck_limit, :influence_cost, :influence_limit, :memory_cost, :minimum_deck_size, :strength, :text, :trash_cost, :uniqueness, :keywords, :updated_at
        key_type :string
      end
    end
  end
end
