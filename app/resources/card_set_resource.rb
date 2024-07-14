# frozen_string_literal: true

# Public resource for CardSet object.
class CardSetResource < ApplicationResource
  primary_endpoint '/card_sets', %i[index show]
  self.default_page_size = 1000

  attribute :id, :string
  attribute :name, :string
  attribute :date_release, :date
  attribute :size, :integer
  attribute :card_cycle_id, :string
  attribute :card_set_type_id, :string
  attribute :legacy_code, :string
  attribute :position, :integer
  attribute :first_printing_id, :string
  attribute :released_by, :string
  attribute :updated_at, :datetime

  belongs_to :card_cycle do
    link do |c|
      format('%s/%s', Rails.application.routes.url_helpers.card_cycles_url, c.card_cycle_id)
    end
  end
  belongs_to :card_set_type

  has_many :printings

  many_to_many :cards, through: :printings

  many_to_many :card_pools

  filter :card_pool_id, :string do
    eq do |scope, card_pool_ids|
      scope.by_card_pool(card_pool_ids)
    end
  end
end
