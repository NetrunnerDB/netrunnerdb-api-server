# frozen_string_literal: true

class AddLegacyCodeToCardCycles < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :card_cycles, :legacy_code, :string
  end
end
