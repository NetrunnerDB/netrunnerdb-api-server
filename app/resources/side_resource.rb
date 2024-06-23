# frozen_string_literal: true

# Public resource for Side objects.
class SideResource < ApplicationResource
  primary_endpoint '/sides', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :updated_at, :datetime

  has_many :factions
  has_many :card_types
  has_many :cards
  # TODO(plural): Add decklist relationship.
  has_many :printings
end
