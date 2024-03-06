class UpdateUnifiedCardsToVersion5 < ActiveRecord::Migration[7.1]
  def change
  
    update_view :unified_cards,
      version: 5,
      revert_to_version: 4,
      materialized: true
  end
end
