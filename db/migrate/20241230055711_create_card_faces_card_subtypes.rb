# frozen_string_literal: true

class CreateCardFacesCardSubtypes < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    create_table :card_faces_card_subtypes, id: false do |t|
      t.string :card_id, null: false
      t.integer :face_index, null: false
      t.string :card_subtype_id
    end
  end
end
