# frozen_string_literal: true

# Public resource for UnifiedCard objects.
class CardResource < ApplicationResource
  primary_endpoint '/cards', %i[index show]

  self.model = UnifiedCard

  attribute :id, :string
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
  attribute :printing_ids, :array_of_strings
  attribute :date_release, :date
  attribute :restriction_ids, :array_of_strings
  attribute :strength, :integer
  attribute :stripped_text, :string
  attribute :text, :string
  attribute :trash_cost, :integer
  attribute :is_unique, :boolean
  attribute :card_subtype_ids, :array_of_strings
  attribute :display_subtypes, :string
  attribute :attribution, :string
  attribute :updated_at, :datetime
  attribute :format_ids, :array_of_strings
  attribute :card_pool_ids, :array_of_strings
  attribute :snapshot_ids, :array_of_strings
  attribute :card_cycle_ids, :array_of_strings
  attribute :card_set_ids, :array_of_strings
  attribute :designed_by, :string
  attribute :printings_released_by, :string
  attribute :pronouns, :string
  attribute :pronunciation_approximation, :string
  attribute :pronunciation_ipa, :string

  # Synthesized attributes
  attribute :card_abilities, :hash
  def packed_restriction_to_map(packed)
    m = {}
    packed.each do |p|
      x = p.split('=')
      m[x[0]] = x[1].to_i
    end
    m
  end

  attribute :restrictions, :hash do
    {
      banned: @object.restrictions_banned,
      global_penalty: @object.restrictions_global_penalty,
      points: packed_restriction_to_map(@object.restrictions_points),
      restricted: @object.restrictions_restricted,
      universal_faction_cost: packed_restriction_to_map(@object.restrictions_universal_faction_cost)
    }
  end
  attribute :latest_printing_id, :string do
    @object.printing_ids[0]
  end

  filter :card_cycle_id, :string do
    eq do |scope, value|
      scope.by_card_cycle(value)
    end
  end

  filter :card_set_id, :string do
    eq do |scope, value|
      scope.by_card_set(value)
    end
  end

  filter :search, :string, single: true do
    eq do |scope, value|
      query_builder = CardSearchQueryBuilder.new(value)
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

  has_many :card_cycles do
    link do |c|
      '%s?filter[id]=%s' % [Rails.application.routes.url_helpers.card_cycles_url, c.card_cycle_ids.join(',')]
    end
  end
  has_many :card_sets do
    link do |c|
      '%s?filter[id]=%s' % [Rails.application.routes.url_helpers.card_sets_url, c.card_set_ids.join(',')]
    end
  end
  many_to_many :card_subtypes do
    link do |c|
      card_subtype_ids = c.card_subtype_ids.empty? ? 'none' : c.card_subtype_ids.join(',')
      '%s?filter[id]=%s' % [Rails.application.routes.url_helpers.card_subtypes_url, card_subtype_ids]
    end
  end
  belongs_to :card_type
  belongs_to :faction
  has_many :printings do
    link do |c|
      '%s?filter[card_id]=%s' % [Rails.application.routes.url_helpers.printings_url, c.id]
    end
  end
  has_many :rulings
  belongs_to :side

  many_to_many :decklists
end
