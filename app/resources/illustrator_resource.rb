# frozen_string_literal: true

# Public resource for Illustrator objects.
class IllustratorResource < ApplicationResource
  primary_endpoint '/illustrators', %i[index show]

  self.attributes_writable_by_default = false

  attribute :id, :string
  attribute :name, :string
  attribute :num_printings, :integer
  attribute :updated_at, :datetime

  many_to_many :printings do
    assign_each do |illustrator, printings|
      printings.select { |p| p.illustrator_ids_in_database.include?(illustrator.id) }
    end
  end
end
