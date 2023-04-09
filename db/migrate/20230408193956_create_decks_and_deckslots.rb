class CreateDecksAndDeckslots < ActiveRecord::Migration[7.0]
  def change
    # ID will be a UUID
    create_table :decks, id: :string do |t|
      t.string :user_id, null: false
      t.string :tags, array: true
      t.string :name, null: false
      t.string :notes, null: false, default: ''
      t.string :side_id, null: false
      t.string :identity_card_id, null: false
      t.integer :deck_size, null: false, default: 0
      t.integer :influence_spent, null: false, default: 0
      t.integer :agenda_points
      t.string :problems, array: true

      t.timestamps

      t.index :tags, using: 'gin'
      t.foreign_key :users
      t.foreign_key :sides
      t.foreign_key :cards, column: :identity_card_id
    end

    create_table :decks_cards, id: false, force: :cascade do |t|
      t.string :deck_id, null: false
      t.string :card_id, null: false
      t.integer :quantity, null: false

      t.index [:deck_id, :card_id], unique: true, name: "index_decks_cards_on_deck_id_and_card_id"
      t.foreign_key :decks
      t.foreign_key :cards
    end

  end
end
