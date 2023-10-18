class AddReleasedByToCyclesAndSets < ActiveRecord::Migration[7.0]
  def change
    add_column :card_cycles, :released_by, :string
    add_column :card_sets, :released_by, :string
  end
end
