class AddPronounsToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :pronouns, :string
  end
end
