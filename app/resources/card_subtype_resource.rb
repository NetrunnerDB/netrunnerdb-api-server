# frozen_string_literal: true

# Public resource for CardSubtype object.
class CardSubtypeResource < ApplicationResource
  primary_endpoint '/card_subtypes', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :updated_at, :datetime

  many_to_many :cards do
    link do |t|
      '%s?filter[card_subtype_id]=%s' % [Rails.application.routes.url_helpers.cards_url, t.id]
    end
  end
  many_to_many :printings do
    link do |t|
      '%s?filter[card_subtype_id]=%s' % [Rails.application.routes.url_helpers.printings_url, t.id]
    end
  end
end
