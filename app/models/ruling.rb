class Ruling < ApplicationRecord
  belongs_to :card
  belongs_to :unified_card, :primary_key => :id, :foreign_key => :card_id
end
