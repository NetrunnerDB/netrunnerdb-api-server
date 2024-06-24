# frozen_string_literal: true

# Public resource for CardCycle objects.
class CardCycleResource < ApplicationResource
  primary_endpoint '/card_cycles', %i[index show]

  self.default_page_size = 1000

  attribute :id, :string
  attribute :name, :string
  attribute :date_release, :date
  attribute :legacy_code, :string
  attribute :card_set_ids, :array_of_strings
  attribute :first_printing_id, :string do
    UnifiedPrinting.where(card_cycle_id: @object.id).minimum(:id)
  end
  attribute :position, :integer
  attribute :released_by, :string
  attribute :updated_at, :datetime

  has_many :card_sets
  has_many :cards, relation_name: :unified_cards
  has_many :printings
end
