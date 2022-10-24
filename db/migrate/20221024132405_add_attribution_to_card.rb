class AddAttributionToCard < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :attribution, :string
    update_view :unified_cards, materialized: true, version: 2, revert_to_version: 1
  end
end
