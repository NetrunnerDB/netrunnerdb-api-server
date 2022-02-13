# frozen_string_literal: true

class Printing < ApplicationRecord
  self.primary_key = :code

  belongs_to :card,
    :primary_key => :code,
    :foreign_key => :card_code
  belongs_to :card_set,
    :primary_key => :code,
    :foreign_key => :card_set_code
  # TODO(plural): Add an association to cycle.

  def format_flavor
    t = flavor || ''
    "<p>#{t.split(/\n/).join('</p><p>')}</p>"
  end
end
