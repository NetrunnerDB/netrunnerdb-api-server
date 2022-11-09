class UnifiedCard < ApplicationRecord
    include CardAbilities

    self.primary_key = :id

    belongs_to :faction
    belongs_to :side
    belongs_to :card_type

    has_many :card_card_subtypes,
      :primary_key => :id,
      :foreign_key => :card_id

    has_many :card_subtypes, :through => :card_card_subtypes

    has_many :unified_printings,
      :primary_key => :id,
      :foreign_key => :card_id
end
