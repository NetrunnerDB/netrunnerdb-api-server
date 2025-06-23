# frozen_string_literal: true

class UpdateUnifiedPrintingsToVersion12 < ActiveRecord::Migration[7.2]
  def change
    update_view :unified_printings,
                version: 12,
                revert_to_version: 11,
                materialized: true
  end
end
