# frozen_string_literal: true

class MwlSubtype < ApplicationRecord
  self.table_name = "mwls_subtypes"

  belongs_to :card_subtype,
    :primary_key => :id,
    :foreign_key => :card_subtype_id
  belongs_to :mwl,
    :primary_key => :id,
    :foreign_key => :mwl_id
end
