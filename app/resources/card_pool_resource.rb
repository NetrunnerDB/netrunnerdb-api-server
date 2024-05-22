class CardPoolResource < ApplicationResource
  primary_endpoint '/card_pools', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :format_id, :string
  attribute :card_cycle_ids, :array_of_strings
  attribute :updated_at, :datetime
  attribute :num_cards, :integer do
    @object.cards.length
  end

  has_one :format
  has_many :card_cycles
  has_many :card_sets
  has_many :cards, relation_name: :unified_cards
  # has_many :snapshots
end
