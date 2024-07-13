# frozen_string_literal: true

# Public Resource for CardPool objects.
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

  belongs_to :format do
    link do |c|
      '%s/%s' % [Rails.application.routes.url_helpers.formats_url, c.format_id]
    end
  end
  has_many :card_cycles do
    link do |c|
      card_cycle_ids = c.card_cycle_ids.empty? ? 'none' : c.card_cycle_ids.join(',')
      '%s?filter[id]=%s' % [Rails.application.routes.url_helpers.card_cycles_url, card_cycle_ids]
    end
  end
  has_many :card_sets do
    link do |c|
      '%s?filter[id]=%s' % [Rails.application.routes.url_helpers.card_sets_url, c.card_set_ids.join(',')]
    end
  end
  # Make a working cards relationship
  # has_many :cards
  has_many :snapshots do
    link do |c|
      '%s?filter[id]=%s' % [Rails.application.routes.url_helpers.snapshots_url, c.snapshot_ids.join(',')]
    end
  end
end
