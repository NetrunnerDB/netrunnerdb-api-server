# frozen_string_literal: true

class MwlSubtype < ApplicationRecord
  self.table_name = "mwls_subtypes"

  belongs_to :subtype,
    :primary_key => :id,
    :foreign_key => :subtype_id
  belongs_to :mwl,
    :primary_key => :id,
    :foreign_key => :mwl_id
end
