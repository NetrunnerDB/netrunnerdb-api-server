# frozen_string_literal: true

# Model for Printing objects.
#
# This uses the unified_printings table because it pre-joins the useful data from related tables.
# These records are immutable since they are sourced from a materialized view.
class Printing < ApplicationRecord
  include CardAbilities

  self.table_name = 'unified_printings'

  self.primary_key = :id

  belongs_to :card
  belongs_to :card_set

  belongs_to :faction
  belongs_to :card_cycle
  belongs_to :card_type

  has_many :printing_card_subtypes,
           primary_key: :id
  has_many :card_subtypes, through: :printing_card_subtypes

  belongs_to :side
  has_many :illustrator_printings,
           primary_key: :id
  has_many :illustrators, through: :illustrator_printings

  # TODO(plural): Add restriction to printing relationships and remove disabled lint check.
  has_many :unified_restrictions, # rubocop:disable Rails/InverseOf
           primary_key: :card_id,
           foreign_key: :card_id
  has_many :card_pool_cards,
           inverse_of: :printings,
           primary_key: :card_id,
           foreign_key: :card_id
  has_many :card_pools, through: :card_pool_cards

  def latest_printing_id
    printing_ids[0]
  rescue StandardError
    nil
  end

  def xlarge_image?
    released_by == 'null_signal_games' &&
      !%w[
        system_core_2019
        magnum_opus_reprint
        salvaged_memories
        system_update_2021
      ].include?(card_set_id)
  end

  def restrictions
    {
      banned: restrictions_banned,
      global_penalty: restrictions_global_penalty,
      points: packed_restriction_to_map(restrictions_points),
      restricted: restrictions_restricted,
      universal_faction_cost: packed_restriction_to_map(restrictions_universal_faction_cost)
    }
  end

  private

  def packed_restriction_to_map(packed)
    m = {}
    packed.each do |p|
      x = p.split('=')
      m[x[0]] = x[1].to_i
    end
    m
  end
end
