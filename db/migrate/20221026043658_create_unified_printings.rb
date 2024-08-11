# frozen_string_literal: true

class CreateUnifiedPrintings < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    create_view :unified_printings, materialized: true
  end
end
