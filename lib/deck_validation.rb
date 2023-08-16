# A class to hold specifications and results from validations.
class DeckValidation
  attr_reader :basic_deckbuilding_rules
  attr_reader :label
  attr_reader :errors

  def initialize(validation_hash)
    @label = nil
    if validation_hash.has_key?('label')
      @label = validation_hash['label']
    end
    @basic_deckbuilding_rules = false
    if validation_hash.has_key?('basic_deckbuilding_rules')
      @basic_deckbuilding_rules = validation_hash['basic_deckbuilding_rules']
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
