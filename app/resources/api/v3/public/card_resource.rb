module API
  module V3
    module Public
      class Api::V3::Public::CardResource < JSONAPI::Resource
        immutable

        model_name 'UnifiedCard'

        attributes :stripped_title, :title, :card_type_id, :side_id, :faction_id, :advancement_requirement
        attributes :agenda_points, :base_link, :cost, :deck_limit, :in_restriction, :influence_cost
        attributes :influence_limit, :memory_cost, :minimum_deck_size, :num_printings, :printing_ids
        attributes :date_release, :restriction_ids, :strength, :stripped_text, :text, :trash_cost, :is_unique
        attributes :card_subtype_ids, :display_subtypes, :attribution, :updated_at
        attributes :format_ids, :card_pool_ids, :snapshot_ids, :card_cycle_ids, :card_set_ids

        # Synthesized attributes
        attributes :card_abilities, :latest_printing_id, :restrictions

        key_type :string

        has_one :side
        has_one :faction
        has_one :card_type
        has_many :card_subtypes
        has_many :printings, relation_name: :unified_printings

        def latest_printing_id
          @model.printing_ids[0]
        end

        def packed_restriction_to_map(packed)
          m = {}
          packed.each do |p|
            x = p.split('=')
            m[x[0]] = x[1].to_i
          end
          return m
        end

        def restrictions
          {
            banned: @model.restrictions_banned,
            global_penalty: @model.restrictions_global_penalty,
            points: packed_restriction_to_map(@model.restrictions_points),
            restricted: @model.restrictions_restricted,
            universal_faction_cost: packed_restriction_to_map(@model.restrictions_universal_faction_cost)
          }
        end

        filters :title, :card_type_id, :side_id, :faction_id, :advancement_requirement
        filters :agenda_points, :base_link, :cost, :deck_limit, :influence_cost
        filters :influence_limit, :memory_cost, :minimum_deck_size, :strength, :trash_cost, :is_unique

        filter :search, apply: ->(records, value, _options) {
          query_builder = CardSearchQueryBuilder.new(value[0])
          if query_builder.parse_error.nil?
              records.left_joins(query_builder.left_joins)
                  .where(query_builder.where, *query_builder.where_values)
                  .distinct
          else
            raise JSONAPI::Exceptions::BadRequest.new(
                'Invalid search query: [%s] / %s' % [value[0], query_builder.parse_error])
          end
        }
      end
    end
  end
end
