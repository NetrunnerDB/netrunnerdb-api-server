# frozen_string_literal: true

# Public resource for CardSetType object.
class CardSetTypeResource < ApplicationResource
  primary_endpoint '/card_set_types', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :description, :string
  attribute :updated_at, :datetime

  has_many :card_sets
  # paginator :none
end
