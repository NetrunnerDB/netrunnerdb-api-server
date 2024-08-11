# frozen_string_literal: true

class CreateUnifiedCards < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    create_view :unified_cards, materialized: true
  end
end
