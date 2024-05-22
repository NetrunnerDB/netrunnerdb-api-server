# frozen_string_literal: true

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
  #  attributes :card_abilities, :latest_printing_id, :restrictions
  attribute :latest_printing_id, :string do
    @object.printing_ids[0]
  end

  belongs_to :side
  belongs_to :faction
  belongs_to :card_type
  # has_many :card_subtypes
end
