module API
  module V3
    module Public
      class Api::V3::Public::PrintingResource < JSONAPI::Resource
        immutable

        model_name 'UnifiedPrinting'

        key_type :string

        # Direct printing attributes
        attributes :card_id, :card_cycle_id, :card_cycle_name, :card_set_id, :card_set_name
        attributes :printed_text, :stripped_printed_text
        attributes :printed_is_unique, :flavor, :display_illustrators, :illustrator_ids, :illustrator_names, :position
        attributes :quantity, :date_release, :updated_at

        # Parent Card attributes, included inline to make printings a bit more useful.
        attributes :advancement_requirement, :agenda_points, :base_link
        attributes :card_type_id, :cost, :deck_limit, :display_subtypes, :card_subtype_ids, :card_subtype_names, :faction_id
        attributes :influence_cost, :influence_limit, :is_unique, :memory_cost, :minimum_deck_size
        attributes :side_id, :strength, :stripped_text, :stripped_title, :text
        attributes :title, :trash_cost, :printing_ids, :num_printings, :restriction_ids, :in_restriction
        attributes :format_ids, :card_pool_ids, :snapshot_ids, :attribution

        # Synthesized attributes
        attributes :card_abilities, :images, :latest_printing_id, :restrictions

        has_one :card, relation_name: :unified_card
        has_one :card_cycle
        has_one :card_set
        has_one :faction
        has_many :illustrators
        has_one :side

        def latest_printing_id
          @model.printing_ids[0]
        end

        def card_abilities
          {
            additional_cost: @model.additional_cost,
            advanceable: @model.advanceable,
            gains_subroutines: @model.gains_subroutines,
            interrupt: @model.interrupt,
            link_provided: @model.link_provided,
            mu_provided: @model.mu_provided,
            num_printed_subroutines: @model.num_printed_subroutines,
            on_encounter_effect: @model.on_encounter_effect,
            performs_trace: @model.performs_trace,
            recurring_credits_provided: @model.recurring_credits_provided,
            rez_effect: @model.rez_effect,
            trash_ability: @model.trash_ability,
          }
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

        # Printing direct attribute filters
        filters :card_id, :card_set_id, :printed_is_unique, :display_illustrators, :position
        filters :quantity, :date_release

        # Card attribute filters
        filters :title, :card_type_id, :side_id, :faction_id, :advancement_requirement
        filters :agenda_points, :base_link, :cost, :deck_limit, :influence_cost, :influence_limit
        filters :memory_cost, :minimum_deck_size, :strength, :trash_cost, :is_unique

        filter :search, apply: ->(records, value, _options) {
          query_builder = PrintingSearchQueryBuilder.new(value[0])
          if query_builder.parse_error.nil?
              records.left_joins(query_builder.left_joins)
                  .where(query_builder.where, *query_builder.where_values)
                  .distinct
          else
            raise JSONAPI::Exceptions::BadRequest.new(
                'Invalid search query: [%s] / %s' % [value[0], query_builder.parse_error])
          end
        }
 
        # Images will return a nested map for different types of images.
        # 'nrdb_classic' represents the JPEGs used for classic netrunnerdb.com.
        # We will likely add other formats like png and webp, as well as various sizes,
        # which will each get their own key in the map. While we are likely to support
        # alt-art versions of cards directly, we may not represent those in the printing
        # directly as we will want to have richer metadata for those images like
        # Illustrator and storefront/purchase URLs.
        def images
          return { "nrdb_classic" => nrdb_classic_images }
        end
        def nrdb_classic_images
          url_prefix = Rails.configuration.x.printing_images.nrdb_classic_prefix
          return {
            "tiny" => "%s/tiny/%s.jpg" % [url_prefix, @model.id],
            "small" => "%s/small/%s.jpg" % [url_prefix, @model.id],
            "medium" => "%s/medium/%s.jpg" % [url_prefix, @model.id],
            "large" => "%s/large/%s.jpg" % [url_prefix, @model.id]
          }
        end
      end
    end
  end
end
