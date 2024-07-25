# frozen_string_literal: true

# Model for restrictions_cards_universal_faction_cost join table.
class RestrictionCardUniversalFactionCost < ApplicationRecord
  self.table_name = 'restrictions_cards_universal_faction_cost'

  belongs_to :restriction,
             primary_key: :id
  belongs_to :card,
             primary_key: :id
end
