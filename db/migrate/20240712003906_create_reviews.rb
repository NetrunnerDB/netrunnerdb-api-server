# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    create_table :reviews do |t|
      t.text :ruling
      t.string :username
      t.text :card_id, null: false

      t.timestamps
    end

    add_foreign_key :reviews, :cards
  end
end
