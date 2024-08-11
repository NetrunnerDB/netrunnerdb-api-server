# frozen_string_literal: true

class AddLegacyCodeToCardSets < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :card_sets, :legacy_code, :string
  end
end
