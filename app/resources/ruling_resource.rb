# frozen_string_literal: true

# Public resource for Side objects.
class RulingResource < ApplicationResource
  primary_endpoint '/rulings', %i[index show]

  attribute :card_id, :string
  attribute :nsg_rules_team_verified, :boolean
  attribute :question, :string
  attribute :answer, :string
  attribute :text_ruling, :string
  attribute :updated_at, :datetime

  belongs_to :card, relation_name: :unified_card
end
