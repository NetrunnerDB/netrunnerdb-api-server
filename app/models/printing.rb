# frozen_string_literal: true

class Printing < ApplicationRecord
  belongs_to :card
  belongs_to :nr_set

  def format_flavor
    t = flavor || ''
    "<p>#{t.split(/\n/).join('</p><p>')}</p>"
  end
end
