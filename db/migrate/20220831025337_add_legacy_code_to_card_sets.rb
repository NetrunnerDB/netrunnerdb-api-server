class AddLegacyCodeToCardSets < ActiveRecord::Migration[7.0]
  def change
    add_column :card_sets, :legacy_code, :string
  end
end
