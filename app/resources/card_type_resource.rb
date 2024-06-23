# frozen_string_literal: true

# Public resource for CardType object.
class CardTypeResource < ApplicationResource
  primary_endpoint '/card_types', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :side_id, :string, only: [:filterable]
  attribute :updated_at, :datetime

  belongs_to :side
  has_many :cards
  has_many :printings
end
