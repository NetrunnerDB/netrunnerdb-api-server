# frozen_string_literal: true

class UpdateUnifiedCardsToVersion3 < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    update_view :unified_cards, materialized: true, version: 3, revert_to_version: 2
  end
end
