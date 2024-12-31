# frozen_string_literal: true

class UpdateUnifiedCardsToVersion8 < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    update_view :unified_cards,
                version: 8,
                revert_to_version: 7,
                materialized: true
  end
end
