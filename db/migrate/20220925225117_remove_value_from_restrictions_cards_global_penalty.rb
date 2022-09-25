class RemoveValueFromRestrictionsCardsGlobalPenalty < ActiveRecord::Migration[7.0]
  def change
    remove_column :restrictions_cards_global_penalty, :value
  end
end
