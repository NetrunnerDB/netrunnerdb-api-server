# frozen_string_literal: true

# Public resource for CardSubtype object.
class CardSubtypeResource < ApplicationResource
  primary_endpoint '/card_subtypes', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :updated_at, :datetime

  # Something busted about card card_subtype_id attribute (no literal match)
  # has_many :cards
  # has_many :printings, relation_name: :unified_printings
end
