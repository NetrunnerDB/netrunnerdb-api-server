# frozen_string_literal: true

class AddPronunciationToCards < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    add_column :cards, :pronunciation_approximation, :string # rubocop:disable Rails/BulkChangeTable
    add_column :cards, :pronunciation_ipa, :string
  end
end
