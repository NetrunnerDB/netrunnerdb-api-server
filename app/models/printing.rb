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

  has_many :unified_restrictions,
           primary_key: :card_id,
           foreign_key: :card_id
  has_many :card_pool_cards,
           primary_key: :card_id,
           foreign_key: :card_id
  has_many :card_pools, through: :card_pool_cards

  def images
    { 'nrdb_classic' => nrdb_classic_images }
  end

  def latest_printing_id
    printing_ids[0]
  rescue StandardError
    nil
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

  def nrdb_classic_images
    url_prefix = Rails.configuration.x.printing_images.nrdb_classic_prefix
    {
      'tiny' => format('%s/tiny/%s.jpg', url_prefix, id),
      'small' => format('%s/small/%s.jpg', url_prefix, id),
      'medium' => format('%s/medium/%s.jpg', url_prefix, id),
      'large' => format('%s/large/%s.jpg', url_prefix, id)
    }
  end

  def packed_restriction_to_map(packed)
    m = {}
    packed.each do |p|
      x = p.split('=')
      m[x[0]] = x[1].to_i
    end
    m
  end
end
