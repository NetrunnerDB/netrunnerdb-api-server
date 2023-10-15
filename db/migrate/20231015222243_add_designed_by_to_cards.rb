class AddDesignedByToCards < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :designed_by, :string
  end
end
