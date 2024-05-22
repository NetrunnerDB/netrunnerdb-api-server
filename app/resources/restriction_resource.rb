# frozen_string_literal: true

# Public resource for Restriction object.
class RestrictionResource < ApplicationResource
  primary_endpoint '/restrictions', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :date_start, :date
  attribute :point_limit, :integer
  attribute :verdicts, :hash do
    verdicts(@object)
  end
  attribute :banned_subtypes, :array_of_strings do
    @object.banned_subtypes.pluck(:card_subtype_id)
  end
  attribute :size, :integer do
    verdicts(@object).map { | (_, v)| v.length() }.sum
  end
  attribute :updated_at, :datetime

  def verdicts(obj)
    { 'banned': obj.banned_cards.pluck(:card_id),
      'restricted': obj.restricted_cards.pluck(:card_id),
      'universal_faction_cost': obj.universal_faction_cost_cards.pluck(:card_id, :value).to_h,
      'global_penalty': obj.global_penalty_cards.pluck(:card_id),
      'points': obj.points_cards.pluck(:card_id, :value).to_h }
  end
end
