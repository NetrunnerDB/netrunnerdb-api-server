# frozen_string_literal: true

# Public resource for CardSubtype object.
class CardSubtypeResource < ApplicationResource
  primary_endpoint '/card_subtypes', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :updated_at, :datetime

  many_to_many :cards do
    link do |t|
      format('%<url>s?filter[card_subtype_id]=%<id>s', url: Rails.application.routes.url_helpers.cards_url, id: t.id)
    end
  end
  many_to_many :printings do
    link do |t|
      format('%<url>s?filter[card_subtype_id]=%<id>s', url: Rails.application.routes.url_helpers.printings_url,
                                                       id: t.id)
    end
  end
end
