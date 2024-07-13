# frozen_string_literal: true

class IllustratorPrinting < ApplicationRecord
  self.table_name = "illustrators_printings"

  belongs_to :illustrator,
             primary_key: :id,
             foreign_key: :illustrator_id
  belongs_to :raw_printing,
             primary_key: :id,
             foreign_key: :printing_id
  belongs_to :unified_sprinting,
             primary_key: :id,
             foreign_key: :printing_id
end
