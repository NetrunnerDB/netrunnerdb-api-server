# frozen_string_literal: true

# A class to hold specifications and results from validations.
class DeckValidation
  attr_reader :basic_deckbuilding_rules, :label, :errors, :format_id, :restriction_id, :card_pool_id, :snapshot_id

  def initialize(validation_hash)
    @label = nil
    @label = validation_hash['label'] if validation_hash.key?('label')
    @basic_deckbuilding_rules = false
    if validation_hash.key?('basic_deckbuilding_rules')
      @basic_deckbuilding_rules = validation_hash['basic_deckbuilding_rules']
    end
    @format_id = nil
    @format_id = validation_hash['format_id'] if validation_hash.key?('format_id')
    @restriction_id = nil
    @restriction_id = validation_hash['restriction_id'] if validation_hash.key?('restriction_id')
    @card_pool_id = nil
    @card_pool_id = validation_hash['card_pool_id'] if validation_hash.key?('card_pool_id')
    @snapshot_id = nil
    @snapshot_id = validation_hash['snapshot_id'] if validation_hash.key?('snapshot_id')

    expand_implied_ids

    @errors = []
  end

  def expand_implied_ids
    if !@snapshot_id.nil? && (@format_id.nil? || @card_pool_id.nil? || @restriction_id.nil?)
      if Snapshot.exists?(@snapshot_id)
        snapshot = Snapshot.find(@snapshot_id)
        @format_id = snapshot.format_id if @format_id.nil?
        @card_pool_id = snapshot.card_pool_id if @card_pool_id.nil?
        @restriction_id = snapshot.restriction_id if @restriction_id.nil?
      end
    elsif !@format_id.nil? && (@snapshot_id.nil? || @card_pool_id.nil? || @restriction_id.nil?)
      if Format.exists?(@format_id)
        format = Format.find(@format_id)
        @snapshot_id = format.active_snapshot_id if @snapshot_id.nil?
        active_snapshot = format.snapshot
        unless active_snapshot.nil?
          @card_pool_id = active_snapshot.card_pool_id if @card_pool_id.nil?
          @restriction_id = active_snapshot.restriction_id if @restriction_id.nil?
        end
      end
    elsif !@card_pool_id.nil? && @format_id.nil?
      if CardPool.exists?(@card_pool_id)
        card_pool = CardPool.find(@card_pool_id)
        @format_id = card_pool.format_id
      end
    elsif !@restriction_id.nil? && @format_id.nil?
      if Restriction.exists?(@restriction_id)
        restriction = Restriction.find(@restriction_id)
        @format_id = restriction.format_id
      end
    end
  end

  def add_error(error)
    @errors << error
  end

  def valid?
    @errors.empty?
  end
end
