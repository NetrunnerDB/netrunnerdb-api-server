# frozen_string_literal: true

class UpdateUnifiedCardsToVersion9 < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    update_view :unified_cards,
                version: 9,
                revert_to_version: 8,
                materialized: true
  end
end
