class AddPositionInSet < ActiveRecord::Migration[7.0]
  def change
    add_column :printings, :position_in_set, :int
  end
end
