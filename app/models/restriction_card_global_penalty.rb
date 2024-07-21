# frozen_string_literal: true

# Model for restrictions_cards_global_penalty join table.
class RestrictionCardGlobalPenalty < ApplicationRecord
  self.table_name = 'restrictions_cards_global_penalty'

  belongs_to :restriction,
             primary_key: :id
  belongs_to :card,
             primary_key: :id
end
