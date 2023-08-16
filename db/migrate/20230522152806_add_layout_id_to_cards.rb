class AddLayoutIdToCards < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :layout_id, :string
  end
end
