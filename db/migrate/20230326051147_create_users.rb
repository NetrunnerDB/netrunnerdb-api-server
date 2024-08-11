# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    create_table :users, id: :string, &:timestamps
  end
end
