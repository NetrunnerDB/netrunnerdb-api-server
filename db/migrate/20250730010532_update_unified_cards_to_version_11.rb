class UpdateUnifiedCardsToVersion11 < ActiveRecord::Migration[7.2]
  def change
    update_view :unified_cards,
      version: 11,
      revert_to_version: 10,
      materialized: true
  end
end
