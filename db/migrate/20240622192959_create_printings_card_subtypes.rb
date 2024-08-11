# frozen_string_literal: true

class CreatePrintingsCardSubtypes < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    create_table :printings_card_subtypes, id: false, force: :cascade do |t|
      t.text :printing_id, null: false
      t.text :card_subtype_id, null: false
      t.index %i[printing_id card_subtype_id], name: 'index_printings_card_subtypes_on_card_id_and_subtype_id'
    end
  end
end
