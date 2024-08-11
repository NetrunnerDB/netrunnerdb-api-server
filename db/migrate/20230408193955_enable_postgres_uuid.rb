# frozen_string_literal: true

class EnablePostgresUuid < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    enable_extension 'pgcrypto'
  end
end
