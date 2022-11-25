class AddNumPrintingsToIllustrators < ActiveRecord::Migration[7.0]
  def change
    add_column :illustrators, :num_printings, :integer
  end
end
