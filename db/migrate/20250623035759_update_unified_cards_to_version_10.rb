# frozen_string_literal: true

class UpdateUnifiedCardsToVersion10 < ActiveRecord::Migration[7.2]
  def change
    update_view :unified_cards,
                version: 10,
                revert_to_version: 9,
                materialized: true
  end
end
