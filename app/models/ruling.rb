class Ruling < ApplicationRecord
  belongs_to :card
  belongs_to :ruling_source
  belongs_to :unified_card, :primary_key => :id, :foreign_key => :card_id
end
