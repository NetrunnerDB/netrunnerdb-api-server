module API
  module V3
    module Public
      class Api::V3::Public::PrintingResource < JSONAPI::Resource
        immutable

        model_name 'UnifiedPrinting'

        key_type :string

        # Direct printing attributes
        attributes :card_id, :card_set_id, :printed_text, :stripped_printed_text
        attributes :printed_is_unique, :flavor, :display_illustrators, :position
        attributes :quantity, :date_release, :updated_at

        # Parent Card attributes, included inline to make printings a bit more useful.
        attributes :advancement_requirement, :agenda_points, :base_link, :card_abilities
        attributes :card_type_id, :cost, :deck_limit, :display_subtypes, :faction_id
        attributes :influence_cost, :influence_limit, :is_unique, :memory_cost, :minimum_deck_size
        attributes :side_id, :strength, :stripped_text, :stripped_title, :text
        attributes :title, :trash_cost

        # Synthesized attributes
        attributes :images

        has_one :card, relation_name: :unified_card
        has_one :card_cycle
        has_one :card_set
        has_one :faction
        has_many :illustrators
        has_one :side
#
#        # Printing direct attribute filters
#        filters :card_id, :card_set_id, :printed_is_unique, :display_illustrators, :position
#        filters :quantity, :date_release
#
#        # Card attribute filters
#        filter :title, apply: ->(records, value, _options){
#          Rails.logger.info(_options)
#          records.joins(:card).where('cards.title = ?', value)
#        }
#        filter :card_type_id, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.card_type_id = ?', value)
#        }
#        filter :side_id, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.side_id = ?', value)
#        }
#        filter :faction_id, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.faction_id= ?', value)
#        }
#
#        filter :advancement_requirement, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.advancement_requirement = ?', value)
#        }
#        filter :agenda_points, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.agenda_points = ?', value)
#        }
#        filter :base_link, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.base_link = ?', value)
#        }
#        filter :cost, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.cost= ?', value)
#        }
#        filter :deck_limit, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.deck_limit= ?', value)
#        }
#        filter :influence_cost, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.influence_cost= ?', value)
#        }
#        filter :influence_limit, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.influence_limit= ?', value)
#        }
#        filter :memory_cost, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.memory_cost= ?', value)
#        }
#        filter :minimum_deck_size, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.minimum_deck_size= ?', value)
#        }
#        filter :strength, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.strength= ?', value)
#        }
#        filter :trash_cost, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.trash_cost= ?', value)
#        }
#        filter :is_unique, apply: ->(records, value, _options){
#          records.joins(:card).where('cards.is_unique= ?', value)
#        }
#        filter :search, apply: ->(records, value, _options) {
#          query_builder = PrintingSearchQueryBuilder.new(value[0])
#          if query_builder.parse_error.nil?
#              records.left_joins(query_builder.left_joins)
#                  .where(query_builder.where, *query_builder.where_values)
#                  .distinct
#          else
#            raise JSONAPI::Exceptions::BadRequest.new(
#                'Invalid search query: [%s] / %s' % [value[0], query_builder.parse_error])
#          end
#        }
# 
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
            trash_ability: @model.trash_ability,
          }
        end
      end
    end
  end
end
