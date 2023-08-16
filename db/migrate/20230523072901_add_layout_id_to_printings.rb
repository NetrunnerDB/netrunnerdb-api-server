class AddLayoutIdToPrintings < ActiveRecord::Migration[7.0]
  def change
    add_column :printings, :layout_id, :string
  end
end
