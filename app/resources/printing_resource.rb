# frozen_string_literal: true

# Public resource for Printing objects.
class PrintingResource < ApplicationResource # rubocop:disable Metrics/ClassLength
  primary_endpoint '/printings', %i[index show]
  self.default_page_size = 1000

  attribute :id, :string
  attribute :card_id, :string
  attribute :card_cycle_id, :string
  attribute :card_cycle_name, :string
  attribute :card_set_id, :string
  attribute :card_set_name, :string

  attribute :flavor, :string
  attribute :display_illustrators, :string
  attribute :illustrator_ids, :array_of_strings do
    @object.illustrator_ids_in_database
  end
  attribute :illustrator_names, :array_of_strings

  attribute :position, :integer
  attribute :position_in_set, :integer
  attribute :quantity, :integer
  attribute :date_release, :date
  attribute :updated_at, :datetime

  attribute :stripped_title, :string
  attribute :title, :string
  attribute :card_type_id, :string
  attribute :side_id, :string
  attribute :faction_id, :string

  # TODO(plural): Move cost and agenda requirements into model.
  attribute :advancement_requirement, :string do
    @object.advancement_requirement == -1 ? 'X' : @object.advancement_requirement
  end
  attribute :cost, :string do
    @object.cost == -1 ? 'X' : @object.cost
  end
  attribute :agenda_points, :integer
  attribute :base_link, :integer
  attribute :deck_limit, :integer
  attribute :in_restriction, :boolean
  attribute :influence_cost, :integer
  attribute :influence_limit, :integer
  attribute :memory_cost, :integer
  attribute :minimum_deck_size, :integer
  attribute :num_printings, :integer
  attribute :is_latest_printing, :boolean
  attribute :printing_ids, :array_of_strings
  attribute :restriction_ids, :array_of_strings
  attribute :strength, :integer
  attribute :stripped_text, :string
  attribute :text, :string
  attribute :trash_cost, :integer
  attribute :is_unique, :boolean
  attribute :card_subtype_ids, :array_of_strings do
    @object.card_subtype_ids_in_database
  end
  attribute :card_subtype_names, :array_of_strings
  attribute :display_subtypes, :string
  attribute :attribution, :string
  attribute :format_ids, :array_of_strings
  attribute :card_pool_ids, :array_of_strings do
    @object.card_pool_ids_in_database
  end
  attribute :snapshot_ids, :array_of_strings
  attribute :card_cycle_ids, :array_of_strings do
    @object.card_cycle_ids_in_database
  end
  attribute :card_cycle_names, :array_of_strings
  attribute :card_set_ids, :array_of_strings do
    @object.card_set_ids_in_database
  end
  attribute :card_set_names, :array_of_strings
  attribute :designed_by, :string
  attribute :released_by, :string
  attribute :printings_released_by, :array_of_strings
  attribute :pronouns, :string
  attribute :pronunciation_approximation, :string
  attribute :pronunciation_ipa, :string

  attribute :images, :hash
  attribute :card_abilities, :hash
  attribute :latest_printing_id, :string
  attribute :restrictions, :hash

  filter :distinct_cards, :boolean do
    eq do |scope, value|
      value ? scope.where('id = printing_ids[1]') : scope
    end
  end

  filter :search, :string, single: true do
    eq do |scope, value|
      query_builder = PrintingSearchQueryBuilder.new(value)
      if query_builder.parse_error.nil?
        scope.left_joins(query_builder.left_joins)
             .where(query_builder.where, *query_builder.where_values)
             .distinct
      else
        raise JSONAPI::Exceptions::BadRequest,
              format('Invalid search query: [%<query>s] / %<error>s', query: value[0], error: query_builder.parse_error)
      end
    end
  end

  belongs_to :card
  belongs_to :card_cycle do
    link do |p|
      format('%<url>s/%<id>s', url: Rails.application.routes.url_helpers.card_cycles_url, id: p.card_cycle_id)
    end
  end
  belongs_to :card_set
  belongs_to :card_type
  belongs_to :faction
  belongs_to :side do
    link do |p|
      format('%<url>s/%<id>s', url: Rails.application.routes.url_helpers.sides_url, id: p.side_id)
    end
  end

  many_to_many :card_subtypes do
    link do |p|
      format('%<url>s?filter[id]=%<ids>s', url: Rails.application.routes.url_helpers.card_subtypes_url,
                                           ids: p.card_subtype_ids_in_database.join(','))
    end
  end

  many_to_many :illustrators do
    link do |p|
      format('%<url>s?filter[id]=%<ids>s', url: Rails.application.routes.url_helpers.illustrators_url,
                                           ids: p.illustrator_ids_in_database.join(','))
    end
  end

  many_to_many :card_pools do
    assign do |printings, _card_pools|
      CardPool.by_printing_ids(printings.map(&:id))
    end
    link do |p|
      format('%<url>s?filter[printing_id]=%<id>s', url: Rails.application.routes.url_helpers.card_pools_url, id: p.id)
    end
  end
end
