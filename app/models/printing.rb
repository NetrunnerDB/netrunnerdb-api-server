# frozen_string_literal: true

class Printing < ApplicationRecord
  belongs_to :card
  belongs_to :card_set
  # TODO(plural): Add an association to cycle.

  def format_flavor
    t = flavor || ''
    "<p>#{t.split(/\n/).join('</p><p>')}</p>"
  end
end
