# frozen_string_literal: true

# Model for restrictions_cards_restricted join table.
class RestrictionCardRestricted < ApplicationRecord
  self.table_name = 'restrictions_cards_restricted'

  belongs_to :restriction,
             primary_key: :id
  belongs_to :card,
             primary_key: :id
end
