class UnifiedRestriction < ApplicationRecord
  def readonly?
    true
  end

  belongs_to :format
  belongs_to :snapshot
  belongs_to :card_pool
  belongs_to :restriction
  belongs_to :card

  scope :cards_restricted_by, ->(restriction_id) { where(
    'restriction_id = ? AND (in_restriction OR is_banned OR is_restricted OR eternal_points > 0 ' +
    'OR has_global_penalty OR universal_faction_cost > 0)', restriction_id) }
end
