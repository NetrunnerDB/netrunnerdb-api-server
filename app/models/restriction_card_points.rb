# frozen_string_literal: true

# Model for restrictions_cards_points join table.
class RestrictionCardPoints < ApplicationRecord
  self.table_name = 'restrictions_cards_points'

  belongs_to :restriction,
             primary_key: :id
  belongs_to :card,
             primary_key: :id
end
