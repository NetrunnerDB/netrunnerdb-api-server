class AddPronunciationToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :pronunciation_approximation, :string
    add_column :cards, :pronunciation_ipa, :string
  end
end
