class AddLegacyCodeToCardCycles < ActiveRecord::Migration[7.0]
  def change
    add_column :card_cycles, :legacy_code, :string
  end
end
