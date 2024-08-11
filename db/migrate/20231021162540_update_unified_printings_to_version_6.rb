# frozen_string_literal: true

class UpdateUnifiedPrintingsToVersion6 < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    update_view :unified_printings,
                version: 6,
                revert_to_version: 5,
                materialized: true
  end
end
