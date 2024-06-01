# frozen_string_literal: true

# Public resource for Faction object.
class FactionResource < ApplicationResource
  primary_endpoint '/factions', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :description, :string
  attribute :is_mini, :boolean
  attribute :side_id, :string
  attribute :updated_at, :datetime

  belongs_to :side
  has_many :cards
  has_many :printings
end
