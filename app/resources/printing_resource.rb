# frozen_string_literal: true

class PrintingResource < ApplicationResource
  primary_endpoint '/printings', %i[index show]

  self.model = UnifiedPrinting

  attribute :id, :string
  attribute :card_id, :string
  attribute :card_cycle_id, :string
  attribute :card_cycle_name, :string
  attribute :card_set_id, :string
  attribute :card_set_name, :string

  attribute :flavor, :string
  attribute :display_illustrators, :string
  attribute :illustrator_ids, :array_of_strings
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
  attribute :advancement_requirement, :string do
    @object.advancement_requirement == -1 ? 'X' : @object.advancement_requirement
  end
  attribute :agenda_points, :integer
  attribute :base_link, :integer
  attribute :cost, :string do
    @object.cost == -1 ? 'X' : @object.cost
  end
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
  attribute :card_subtype_ids, :array_of_strings
  attribute :card_subtype_names, :array_of_strings
  attribute :display_subtypes, :string
  attribute :attribution, :string
  attribute :format_ids, :array_of_strings
  attribute :card_pool_ids, :array_of_strings
  attribute :snapshot_ids, :array_of_strings
  attribute :card_cycle_ids, :array_of_strings
  attribute :card_set_ids, :array_of_strings
  attribute :designed_by, :string
  attribute :released_by, :string
  # TODO(plural): is printings_released_by needed?
  attribute :printings_released_by, :string
  attribute :pronouns, :string
  attribute :pronunciation_approximation, :string
  attribute :pronunciation_ipa, :string

  def images(id)
    { 'nrdb_classic' => nrdb_classic_images(id) }
  end

  def nrdb_classic_images(id)
    url_prefix = Rails.configuration.x.printing_images.nrdb_classic_prefix
    {
      'tiny' => format('%s/tiny/%s.jpg', url_prefix, id),
      'small' => format("%s/small/%s.jpg", url_prefix, id),
      'medium' => format("%s/medium/%s.jpg", url_prefix, id),
      'large' => format('%s/large/%s.jpg', url_prefix, id)
    }
  end
  attribute :images, :hash do
    images(@object.id)
  end
  # Synthesized attributes
  #  attributes :card_abilities, :latest_printing_id, :restrictions
  attribute :latest_printing_id, :string do
    @object.printing_ids[0]
  end

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
              format('Invalid search query: [%s] / %s', value[0], query_builder.parse_error)
      end
    end
  end

  belongs_to :card
  belongs_to :card_cycle
  belongs_to :card_set
  belongs_to :side
  belongs_to :faction
  belongs_to :card_type
  # TODO(plural): Fix these relationships.
  # has_many :illustrators
  # has_many :card_subtypes
end
