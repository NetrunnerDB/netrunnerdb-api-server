class CreateDecksAndDeckslots < ActiveRecord::Migration[7.0]
  def change
    # ID will be a UUID
    create_table :decks, id: :uuid do |t|
      t.string :user_id, null: false
      t.boolean :follows_basic_deckbuilding_rules, null: false, default: true
      t.string :identity_card_id, null: false
      t.string :side_id, null: false
      t.string :name, null: false
      t.string :notes, null: false, default: ''
      t.string :tags, array: true

      t.timestamps

      t.index :tags, using: 'gin'
      t.foreign_key :users
      t.foreign_key :sides
      t.foreign_key :cards, column: :identity_card_id
    end

    create_table :decks_cards, id: false, force: :cascade do |t|
      t.uuid :deck_id, null: false
      t.string :card_id, null: false
      t.integer :quantity, null: false

      t.index [:deck_id, :card_id], unique: true, name: "index_decks_cards_on_deck_id_and_card_id"
      t.foreign_key :decks
      t.foreign_key :cards
    end

  end
end
