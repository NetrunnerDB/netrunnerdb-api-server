# frozen_string_literal: true

# Public resource for Restriction object.
class RestrictionResource < ApplicationResource
  primary_endpoint '/restrictions', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :date_start, :date
  attribute :point_limit, :integer
  attribute :format_id, :string
  attribute :verdicts, :hash
  attribute :banned_subtypes, :array_of_strings do
    @object.banned_subtypes.pluck(:card_subtype_id)
  end
  attribute :size, :integer
  attribute :updated_at, :datetime

  belongs_to :format
end
