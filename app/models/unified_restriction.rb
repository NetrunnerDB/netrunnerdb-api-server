class UnifiedRestriction < ApplicationRecord
  def readonly?
    true
  end

  belongs_to :format
  belongs_to :snapshot
  belongs_to :card_pool
  belongs_to :restriction
  belongs_to :card

  # Need a scope for this query:
  #   in_restriction OR is_banned OR is_restricted OR eternal_points > 0 OR has_global_penalty OR universal_faction_cost > 0);
end
