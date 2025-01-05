# frozen_string_literal: true

class UpdateUnifiedPrintingsToVersion10 < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    update_view :unified_printings,
                version: 10,
                revert_to_version: 9,
                materialized: true
  end
end
