# frozen_string_literal: true

class CreateDecklistsAndDecklistSlots < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    # ID will be a UUID
    create_table :decklists, id: :uuid do |t|
      # user_id will not be a foreign key until more user stuff is sorted.
      t.string :user_id, null: false
      t.boolean :follows_basic_deckbuilding_rules, null: false, default: true
      t.string :identity_card_id, null: false
      t.string :side_id, null: false
      t.string :name, null: false
      t.string :notes, null: false, default: ''
      t.string :tags, array: true

      t.timestamps

      t.index :tags, using: 'gin'
      t.foreign_key :sides
      t.foreign_key :cards, column: :identity_card_id
    end

    create_table :decklists_cards, id: false, force: :cascade do |t|
      t.uuid :decklist_id, null: false
      t.string :card_id, null: false
      t.integer :quantity, null: false

      t.index %i[decklist_id card_id], unique: true, name: 'index_decklists_cards_on_decklist_id_and_card_id'
      t.foreign_key :decklists
      t.foreign_key :cards
    end
  end
end
