# frozen_string_literal: true

# Public resource for Illustrator objects.
class IllustratorResource < ApplicationResource
  primary_endpoint '/illustrators', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :num_printings, :integer
  attribute :updated_at, :datetime

  many_to_many :printings
end
