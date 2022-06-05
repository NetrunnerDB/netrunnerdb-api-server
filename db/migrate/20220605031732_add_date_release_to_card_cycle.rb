class AddDateReleaseToCardCycle < ActiveRecord::Migration[7.0]
  def change
    add_column :card_cycles, :date_release, :date
  end
end
