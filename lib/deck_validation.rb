# A class to hold specifications and results from validations.
class DeckValidation
  attr_reader :basic_deckbuilding_rules
  attr_reader :label
  attr_reader :errors
  attr_reader :format_id
  attr_reader :restriction_id
  attr_reader :card_pool_id
  attr_reader :snapshot_id

  def initialize(validation_hash)
    @label = nil
    if validation_hash.has_key?('label')
      @label = validation_hash['label']
    end
    @basic_deckbuilding_rules = false
    if validation_hash.has_key?('basic_deckbuilding_rules')
      @basic_deckbuilding_rules = validation_hash['basic_deckbuilding_rules']
    end
    @format_id = nil
    if validation_hash.has_key?('format_id')
      @format_id = validation_hash['format_id']
    end
    @restriction_id = nil
    if validation_hash.has_key?('restriction_id')
      @restriction_id = validation_hash['restriction_id']
    end
    @card_pool_id = nil
    if validation_hash.has_key?('card_pool_id')
      @card_pool_id = validation_hash['card_pool_id']
    end
    @snapshot_id = nil
    if validation_hash.has_key?('snapshot_id')
      @snapshot_id = validation_hash['snapshot_id']
    end

    @errors = []
  end

  def expand_implied_ids
    # TODO: Update validation message to include expansions

    if !@snapshot_id.nil? and (@format_id.nil? or @card_pool_id.nil? or @restriction_id.nil?)
      snapshot = Snapshot.find(@snapshot_id)
      if !snapshot.nil?
        if @format_id.nil?
          @format_id = snapshot.format_id
        end
        if @card_pool_id.nil?
          @card_pool_id = snapshot.card_pool_id
        end
        if @restriction_id.nil?
          @restriction_id = snapshot.restriction_id
        end
      end
    elsif !@format_id.nil? and (@snapshot_id.nil? or @card_pool_id.nil? or @restriction_id.nil?)
      format = Format.find(@format_id)
      if !format.nil?
        if @snapshot_id.nil?
          @snapshot_id = format.active_snapshot_id
        end
        active_snapshot = format.snapshot
        if !active_snapshot.nil?
          if @card_pool_id.nil?
            @card_pool_id = active_snapshot.card_pool_id
          end
          if @restriction_id.nil?
            @restriction_id = active_snapshot.restriction_id
          end
        end
      end
    elsif !@card_pool_id.nil? and @format_id.nil?
      card_pool = CardPool.find(@card_pool_id)
      if !card_pool.nil?
        @format_id = card_pool.format_id
      end
# TODO: uncomment once restrictions have formats.
#    elsif !@restriction_id.nil? and @format_id.nil?
#      restriction = Restriction.find(@restriction_id)
#      if !restriction.nil?
#        @format_id = restriction.format_id
#      end
    end
  end

  def add_error(e)
    @errors << e
  end

  def is_valid?
    return @errors.size == 0
  end
end
