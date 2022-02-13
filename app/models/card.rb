# frozen_string_literal: true

class Card < ApplicationRecord
  self.primary_key = :code

  belongs_to :side,
    :primary_key => :code,
    :foreign_key => :side_code
  belongs_to :faction,
    :primary_key => :code,
    :foreign_key => :faction_code
  belongs_to :card_type,
    :primary_key => :code,
    :foreign_key => :card_type_code
  has_many :card_subtypes,
    :primary_key => :code,
    :foreign_key => :card_code
  has_many :subtypes, :through => :card_subtypes
  has_many :printings,
    :primary_key => :code,
    :foreign_key => :card_code

  validates :code, uniqueness: true
  validates :name, uniqueness: true

  def versions
    printings.includes(card_set: :cycle).order(date_release: :desc)
  end

  def strength_selector
    if strength.present?
      strength
    elsif agenda_points.present?
      agenda_points
    elsif trash_cost.present?
      trash_cost
    else
      ''
    end
  end

  def type_builder
    c_type = "<strong>#{card_type.name}".dup
    c_type << if subtypes.present?
                ":</strong> #{subtypes}"
              else
                '</strong>'
              end
    c_type.freeze
  end

  def format_text
    t = text || ''.dup

    t.gsub(/(\[subroutine\])/, '<abbr class="icon icon-subroutine">\1</abbr>')
     .gsub(/(\[credit\])/, '<abbr class="icon icon-credit">\1</abbr>')
     .gsub(/(\[trash\])/, '<abbr class="icon icon-trash">\1</abbr>')
     .gsub(/(\[click\])/, '<abbr class="icon icon-click">\1</abbr>')
     .gsub(/(\[recurring-credit\])/,
           '<abbr class="icon icon-recurring-credit">\1</abbr>')
     .gsub(/(\[mu\])/, '<abbr class="icon icon-mu">\1</abbr>')
     .gsub(/(\[link\])/, '<abbr class="icon icon-link">\1</abbr>')
     .gsub(/(\[anarch\])/, '<abbr class="icon icon-anarch">\1</abbr>')
     .gsub(/(\[criminal\])/, '<abbr class="icon icon-criminal">\1</abbr>')
     .gsub(/(\[shaper\])/, '<abbr class="icon icon-shaper">\1</abbr>')
     .gsub(/(\[jinteki\])/, '<abbr class="icon icon-jinteki">\1</abbr>')
     .gsub(/(\[haas-bioroid\])/, '<abbr class="icon icon-haas-bioroid">')
     .gsub(/(\[nbn\])/, '<abbr class="icon icon-nbn">\1</abbr>')
     .gsub(/(\[weyland-consortium\])/,
           '<abbr class="icon icon-weyland-consortium">\1</abbr>')
     .gsub(%r{<trace>([^<]+) ([X\d]+)<\/trace>}, '<strong>\1 [\2]</strong> –')
     .gsub(%r{<errata>(.+)<\/errata>},
           '<em>\1<abbr class="glyphicon glyphicon-alert">\1</abbr> $1</em>')
     .split(/\n/).join('</p><p>')
  end

  def influence_builder
    if influence_cost.present?
      inf = "<span class=\"#{faction.code.dasherize}\">".dup
      inf << "#{'●' * influence_cost}</span>"
      inf << '○' * (5 - influence_cost)
      inf
    else
      ''
    end
  end
end
