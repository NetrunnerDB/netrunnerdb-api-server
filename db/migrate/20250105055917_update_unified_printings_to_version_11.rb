# frozen_string_literal: true

class UpdateUnifiedPrintingsToVersion11 < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    update_view :unified_printings,
                version: 11,
                revert_to_version: 10,
                materialized: true
  end
end
