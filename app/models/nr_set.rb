# frozen_string_literal: true

class NrSet < ApplicationRecord
  belongs_to :nr_cycle, optional: true
  belongs_to :nr_set_type
end
