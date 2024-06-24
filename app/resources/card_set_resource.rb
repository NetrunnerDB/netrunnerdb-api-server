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
  attribute :first_printing_id, :string do
    first_printing = UnifiedPrinting.find_by(card_set_id: @object.id, position_in_set: 1)
    first_printing&.id
  end
  attribute :released_by, :string
  attribute :updated_at, :datetime

  belongs_to :card_cycle do
    link do |c|
      '%s/%s' % [Rails.application.routes.url_helpers.card_cycles_url, c.card_cycle_id]
    end
  end
  belongs_to :card_set_type

  has_many :cards, relation_name: :unified_cards

  has_many :printings
end
