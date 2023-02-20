class CreateRulings < ActiveRecord::Migration[7.0]
  def change
    create_table :rulings do |t|
      t.string :card_id, null: false
      t.string :ruling_source_id, null:false
      t.string :question
      t.string :answer
      t.string :text_ruling
      t.timestamps
    end

    add_foreign_key :rulings, :cards
    add_foreign_key :rulings, :ruling_sources
  end
end
