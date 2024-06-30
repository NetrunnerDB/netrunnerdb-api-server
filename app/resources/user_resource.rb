# frozen_string_literal: true

# Private resource for the User objects.
class UserResource < PrivateApplicationResource
  primary_endpoint '/user', %i[index]
  self.autolink = false

  attribute :id, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  has_many :decks do
    link do |user|
      '%s?filter[user_id]=%s' % [Rails.application.routes.url_helpers.decks_url, user.id]
    end
  end
  has_many :decklists do
    link do |user|
      '%s?filter[user_id]=%s' % [Rails.application.routes.url_helpers.decklists_url, user.id]
    end
  end
end
