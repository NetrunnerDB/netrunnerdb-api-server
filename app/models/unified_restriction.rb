class UnifiedRestriction < ApplicationRecord
  def readonly?
    true
  end

  belongs_to :format
  belongs_to :snapshot
  belongs_to :card_pool
  belongs_to :restriction
  belongs_to :card
end
