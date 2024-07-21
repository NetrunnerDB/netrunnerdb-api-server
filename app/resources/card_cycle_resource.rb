# frozen_string_literal: true

# Public resource for CardCycle objects.
class CardCycleResource < ApplicationResource
  primary_endpoint '/card_cycles', %i[index show]

  self.default_page_size = 1000

  attribute :id, :string
  attribute :name, :string
  attribute :date_release, :date
  attribute :legacy_code, :string
  attribute :card_set_ids, :array_of_strings
  attribute :first_printing_id, :string do
    Printing.where(card_cycle_id: @object.id).minimum(:id)
  end
  attribute :position, :integer
  attribute :released_by, :string
  attribute :updated_at, :datetime

  has_many :card_sets
  has_many :printings
  many_to_many :cards, through: :printings do
    link do |c|
      format('%<url>s?filter[card_cycle_id]=%<card_cycle_id>s', url: Rails.application.routes.url_helpers.cards_url,
                                                                card_cycle_id: c.id)
    end
  end

  many_to_many :card_pools

  filter :card_pool_id, :string do
    eq do |scope, card_pool_ids|
      scope.by_card_pool(card_pool_ids)
    end
  end
end
