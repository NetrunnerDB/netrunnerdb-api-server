# frozen_string_literal: true

# Mapping between illustrators and printings.
class IllustratorPrinting < ApplicationRecord
  self.table_name = 'illustrators_printings'

  belongs_to :illustrator
  belongs_to :raw_printing,
             primary_key: :id,
             foreign_key: :printing_id
  belongs_to :printing
end
