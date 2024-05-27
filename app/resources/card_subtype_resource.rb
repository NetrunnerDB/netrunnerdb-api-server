# frozen_string_literal: true

# Public resource for CardSubtype object.
class CardSubtypeResource < ApplicationResource
  primary_endpoint '/card_subtypes', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :updated_at, :datetime

  # TODO(plural): Add filters that work with the arrays.
  # has_many :cards
  # has_many :printings
end
