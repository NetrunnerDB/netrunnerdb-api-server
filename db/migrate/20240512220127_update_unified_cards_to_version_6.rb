# frozen_string_literal: true

class UpdateUnifiedCardsToVersion6 < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    update_view :unified_cards,
                version: 6,
                revert_to_version: 5,
                materialized: true
  end
end
