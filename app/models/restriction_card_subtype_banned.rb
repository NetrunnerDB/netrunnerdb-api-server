# frozen_string_literal: true

# Model for restrictions_card_subtypes_banned join table.
class RestrictionCardSubtypeBanned < ApplicationRecord
  self.table_name = 'restrictions_card_subtypes_banned'

  belongs_to :restriction,
             primary_key: :id
  belongs_to :card_subtype,
             primary_key: :id
end
