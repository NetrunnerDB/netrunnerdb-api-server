class AddPositionToCardCycle < ActiveRecord::Migration[7.0]
  def change
    add_column :card_cycles, :position, :integer
  end
end
