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

  def add_error(e)
    @errors << e
  end

  def is_valid?
    return @errors.size == 0
  end
end
