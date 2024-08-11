# frozen_string_literal: true

class UpdateUnifiedPrintingsToVersion5 < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    update_view :unified_printings,
                version: 5,
                revert_to_version: 4,
                materialized: true
  end
end
