class UnifiedCard < ApplicationRecord
    self.primary_key = :id 

    has_many :unified_printings,
      :primary_key => :id,
      :foreign_key => :card_id
end
