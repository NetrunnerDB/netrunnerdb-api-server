# frozen_string_literal: true

# Model for restrictions_cards_banned join table.
class RestrictionCardBanned < ApplicationRecord
  self.table_name = 'restrictions_cards_banned'

  belongs_to :restriction,
             primary_key: :id
  belongs_to :card,
             primary_key: :id
end
