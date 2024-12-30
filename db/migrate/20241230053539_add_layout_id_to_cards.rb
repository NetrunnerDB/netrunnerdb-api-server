class AddLayoutIdToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :layout_id, :string, default: 'normal', null: false
  end
end
