# frozen_string_literal: true

class MwlCard < ApplicationRecord
  self.table_name = "mwls_cards"

  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :mwl,
    :primary_key => :id,
    :foreign_key => :mwl_id
end
