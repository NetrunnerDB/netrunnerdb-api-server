# frozen_string_literal: true

class RenameReviewRulingToBody < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    change_table :reviews do |t|
      t.rename :ruling, :body
    end
  end
end
