# frozen_string_literal: true

# Public resource for CardSubtype object.
class CardSubtypeResource < ApplicationResource
  primary_endpoint '/card_subtypes', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :updated_at, :datetime

  many_to_many :cards do
    link do |p|
      helpers = Rails.application.routes.url_helpers
      helpers.cards_url(params: { filter: { card_subtype_id: p.id } })
    end
  end
  many_to_many :printings do
    link do |p|
      helpers = Rails.application.routes.url_helpers
      helpers.printings_url(params: { filter: { card_subtype_id: p.id } })
    end
  end
end
