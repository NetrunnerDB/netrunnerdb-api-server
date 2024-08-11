# frozen_string_literal: true

class UpdateUnifiedCardsToVersion4 < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    update_view :unified_cards,
                version: 4,
                revert_to_version: 3,
                materialized: true
  end
end
