# frozen_string_literal: true

class RemoveValueFromRestrictionsCardsGlobalPenalty < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    remove_column :restrictions_cards_global_penalty, :value # rubocop:disable Rails/ReversibleMigration
  end
end
