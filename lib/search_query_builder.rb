class SearchQueryBuilder

  # A struct for representing an accepted field and its properties
  # :type is one of :array, :boolean, :date, :integer, :string
  FieldData = Struct.new(:type, :sql, :keywords, :documentation)

  # Override this in child classes to define the valid fields for each builder
  @fields = []

  # Helpers to generate the per-table field names
  def self.card_field(name)
    'unified_cards.%s' % name
  end
  def self.printing_field(name)
    'unified_printings.%s' % name
  end

  def self.card(field)
    {:c => card_field(field)}
  end
  def self.printing(field)
    {:p => printing_field(field)}
  end
  def self.both(field)
    {:c => card_field(field), :p => printing_field(field)}
  end

  @@search_filter_docs = <<-EOM
#### Notes

The search syntax is the same between the `Card` and `Printing` endpoints aside from some fields that only exist in one or the other.

In constructed URLs for calls to the API, ensure that you URL Encode the value to the `filter[search]` argument.

#### Search Query Structure

* A search query is a series of one or more conditions separated by one or more spaces (which acts as an implicit `and`) or explicit conjuctions (`and` and `or`):
  * `condition1 condition2 condition3` - gets all cards that meet the requirements of all three conditions
* Multiple values for a given term can be provided with `|` ( acts as `or`) or `&`.
  * `text:"Runner is tagged"&meat` will return all cards with both `Runner is tagged` and `meat` in their text.
  * `text:"Runner is tagged"|meat` will return all cards with either `Runner is tagged` or `meat` in their text.
* Each condition must be some or all of the name of a card or a criteria search:
  * `Street` - gets all cards with "Street" in their name
  * `x:credit` - gets all cards with "credit" in their ability text (see below for the full list of accepted criteria)
* Note that conditions containing spaces must be surrounded with quotation marks:
  * `"Street Magic"` or `x:"take all credits"`
* Negation operators
  * In addition to using a match or negated match operator (like `faction!anarch`), you can preface any condition with `!` or `-` to negate the whole condition.
  * `f:adam -card_type:resource` will return all non-resource Adam cards.
  * `f:apex !card_type:event` will return all non-event Apex cards.
* Conjunctions and grouping
  * Explicit `and` and `or` conjunctions are supported by the Search Syntax.
    * `t:identity and f:criminal` will return all Criminal Identities.
  * Explicit parenthesis will control grouping.
    * `(f:criminal or f:shaper) and t:identity` or `(f:criminal or f:shaper) t:identity` will return all Criminal or Shaper Identities.
  * A literal `and` or one using a space will have a higher precedence than an `or`.
    * `f:criminal or f:shaper and t:identity` and `f:criminal or f:shaper t:identity` will return all Criminal cards and Shaper Identities.

#### Field Types and Operators

There are 5 types of fields in the Search Filter:

* **Array** - supports the `:` (an element in the array is an exact match) and `!` (an element in the array is not an exact match) operators.
  * `card_pool_ids:eternal|snapshot` returns all cards in the eternal or snapshot card pools.
  * `card_pool!snapshot` returns all cards not in the snapshot card pool.
* **Boolean** - supports the `:` (match) and `!` (negated match) operators.  `true`, `false`, `t`, `f`, `1`, and `0` are all acceptable values.
  * `advanceable:true`, `advanceable:t`, and `advanceable:1` will all return all results where advanceable is true.
* **Date** - supports the `:` (match),  `!` (negated match), `<`, `<=`, `>`, and `>=` operators.  Requires date in `YYYY-MM-DD` format.
  * `release_date<=2020-01-01` will return everything with a release date less than or equal to New Year's Day, 2020.
* **Integer** - supports the `:` (match),  `!` (negated match), `<`, `<=`, `>`, and `>=` operators.  Requires simple integer input.
  * For cards that have an X value, you can match with X, like `cost:X` (case insensitive).  an X value is treated as -1 behind the scenes.
* **String** - supports the `:` (LIKE) and `!` (NOT LIKE) operators. Input is transformed to lower case and the `%` decorations are added automatically, turning a query like `title:street` into a SQL fragment like `LOWER(stripped_title) LIKE '%street%`.
  * `title:clearance` returns everything with clearance in the title.
  * `title!clearance` returns everything without clearance in the title.

  EOM

  # Since UnifiedPrinting contains so much of UnifiedCard, centralize the field
  # definitions with an indication of if they apply to one or both.
  # The documentation string here will be passed on to the generated API docs as well.
  # Note: this does not yet have arrays of name fields supported due to complications with
  #       needing to UNNEST array fields to handle LIKE queries for array field elements.
  @@full_fields = [
    FieldData.new(:array, card('card_cycle_ids'), ['card_cycle', 'c'],
      '`card_cycle_id`s for printings of a card.'),
    FieldData.new(:array, both('card_pool_ids'), ['card_pool', 'z'],
      '`card_pool_id`s for a card pool containing a card.'),
    FieldData.new(:array, card('card_set_ids'), ['card_set', 'e'],
      '`card_set_id` for a card, pulled in via printing.'),
    FieldData.new(:array, both('lower_card_subtype_names'), ['card_subtype', 's'],
      'text names for card subtypes, matched as lowercase.'),
    FieldData.new(:array, both('card_subtype_ids'), ['card_subtype_id'],
      '`card_subtype_id`s for the card.'),
    FieldData.new(:array, both('restrictions_points'), ['eternal_points'],
      'Concatenation of `restriction_id` and an Eternal Points value, joined by a hyphen, like `eternal_points:eternal_points_list_22_09-2`.'),
    FieldData.new(:array, both('format_ids'), ['format'],
      '`format_id` for any format containing the card at any time.'),
    FieldData.new(:array, both('restrictions_global_penalty'), ['has_global_penalty'],
      '`restriction_id` restricting the card with a global penalty, like `has_global_penalty:napd_mwl_1_1`.'),
    FieldData.new(:array, printing('illustrator_ids'), ['illustrator_id'],
      '`illustrator_id` for an illustrator for the printing.'),
    FieldData.new(:array, both('restrictions_banned'), ['is_banned'],
      '`restriction_id` specifying the card as banned, like `is_banned:standard_ban_list_22_08`.'),
    FieldData.new(:array, both('restrictions_restricted'), ['is_restricted'],
      '`restriction_id` specifying the card as banned, like `is_restricted:standard_mwl_3_4_b`.'),
    FieldData.new(:array, card('printing_ids'), ['printing_id'],
      '`printing_id` for any printing of this card.'),
    FieldData.new(:array, both('printings_released_by'), ['printings_released_by'],
      'All organizations that have released printings for a card.'),
    FieldData.new(:array, both('restriction_ids'), ['restriction_id', 'b'],
      '`restriction_id` specifying the card for any reason, like: `restriction_id:eternal_points_list_22_09`'),
    FieldData.new(:array, both('snapshot_ids'), ['snapshot'],
      '`snapshot_id` of a snapshot containing a card.'),
    FieldData.new(:array, both('restrictions_universal_faction_cost'), ['universal_faction_cost'],
      'Concatenation of `restriction_id` and a Universal Faction Cost value, joined by a hyphen, like `universal_faction_cost:napd_mwl_1_2-3`.'),
    FieldData.new(:boolean, both('additional_cost'), ['additional_cost'],
      'Does the card text specify an additional cost to play?'),
    FieldData.new(:boolean, both('advanceable'), ['advanceable'],
      'Is the card advanceable?'),
    FieldData.new(:boolean, both('gains_subroutines'), ['gains_subroutines'],
      'Does the card text allow for adding or gaining subroutines?'),
    FieldData.new(:boolean, both('in_restriction'), ['in_restriction'],
      'Is the card specified on any Restriction list?'),
    FieldData.new(:boolean, both('interrupt'), ['interrupt'],
      'Does the card have an interrupt ability?'),
    FieldData.new(:boolean, both('is_unique'), ['is_unique', 'u'],
      'Is the card unique?'),
    FieldData.new(:boolean, both('on_encounter_effect'), ['on_encounter_effect'],
      'Does the card text specify an on encounter effect?'),
    FieldData.new(:boolean, both('performs_trace'), ['performs_trace'],
      'Does the card perform a trace?'),
    FieldData.new(:boolean, both('rez_effect'), ['rez_effect'],
      'Does the card have a rez effect?'),
    FieldData.new(:boolean, both('trash_ability'), ['trash_ability'],
      'Does the card provide a trash ability?'),
    FieldData.new(:date, both('date_release'), ['release_date', 'date_release', 'r'],
      'The earliest release date for a card or the release date for the set for a printing.'),
    FieldData.new(:integer, both('advancement_requirement'), ['advancement_cost', 'g'],
      'The `advancement_cost` value for an agenda. Accepts positive integers and X (case-insensitive).'),
    FieldData.new(:integer, both('agenda_points'), ['agenda_points', 'v'],
      'The printed number of agenda points for the agenda.'),
    FieldData.new(:integer, both('base_link'), ['base_link', 'l'],
      'The printed link value for an Identity.'),
    FieldData.new(:integer, both('cost'), ['cost', 'o'],
      'The printed cost of a card. Accepts positive integers and X (case-insensitive).'),
    FieldData.new(:integer, both('influence_cost'), ['influence_cost', 'n'],
      'The influence cost or number of influence pips for the card.'),
    FieldData.new(:integer, both('link_provided'), ['link_provided'],
      'The amount of link provided.'),
    FieldData.new(:integer, both('memory_cost'), ['memory_usage', 'm'],
      'The memory (MU) cost of this card.'),
    FieldData.new(:integer, both('mu_provided'), ['mu_provided'],
      'The amount of memory (MU) provided by the card.'),
    FieldData.new(:integer, both('num_printed_subroutines'), ['num_printed_subroutines'],
      'The number of printed subroutines on this card.'),
    FieldData.new(:integer, both('num_printings'), ['num_printings'],
      'Count of unique printings for this card.'),
    FieldData.new(:integer, printing('position'), ['position'],
      'The position of the printing in a card set.'),
    FieldData.new(:integer, printing('quantity'), ['quantity', 'y'],
      'The number of copies of a printing in the set.'),
    FieldData.new(:integer, both('recurring_credits_provided'), ['recurring_credits_provided'],
      'The number of recurring credits provided by this card. Accepts integers or X.'),
    FieldData.new(:integer, both('strength'), ['strength', 'p'],
      'The strength of the card. Accepts integers or X.'),
    FieldData.new(:integer, both('trash_cost'), ['trash_cost', 'h'],
      'The trash cost of this card.'),
    FieldData.new(:string, both('attribution'), ['attribution'],
      'The designer of this card text, if specified.'),
    FieldData.new(:string, printing('card_cycle_id'), ['card_cycle', 'c'],
      '`card_cycle_id` for a printing.'),
    FieldData.new(:string, printing('card_id'), ['card_id'],
      '`card_id` for a printing.'),
    FieldData.new(:string, printing('card_set_id'), ['card_set', 'e'],
      '`card_set_id` for printing.'),
    FieldData.new(:string, both('card_type_id'), ['card_type', 't'],
      '`card_type_id` of this card.'),
    FieldData.new(:string, both('designed_by'), ['designed_by'],
      'The organization that designed the card.'),
    FieldData.new(:string, printing('display_illustrators'), ['illustrator', 'i'],
      'The printed version of the illustrator credits, with multiple illustrators separated by commas.'),
    FieldData.new(:string, both('faction_id'), ['faction', 'f'],
      '`faction_id` of this card.'),
    FieldData.new(:string, printing('flavor'), ['flavor', 'flavour', 'a'],
      'The flavor text for a printing.'),
    FieldData.new(:string, printing('released_by'), ['released_by'], 'The organization that released the printing.'),
    FieldData.new(:string, both('side_id'), ['side', 'd'],
      '`side_id` of the card.'),
    FieldData.new(:string, both('stripped_text'), ['text', 'x'],
      'The text of a card, stripped of all formatting symbols and marks.'),
    FieldData.new(:string, both('stripped_title'), ['title', '_'],
      'The title of a card, stripped of all formatting symbols and marks.'),
  ]
  def self.search_filter_docs
    @@search_filter_docs
  end

  # This lets us use the inherited instance of @fields
  class << self
    attr_reader :fields
  end
  def fields
    self.class.fields
  end

  # Maps operators as accepted by the parser to their SQL counterparts
  @@operators = {
    :array => {
      ':' => '',
      '!' => 'NOT',
    },
    :boolean => {
      ':' => '=',
      '!' => '!=',
    },
    :date => {
        ':' => '=',
        '!' => '!=',
        '<' => '<',
        '<=' => '<=',
        '>' => '>',
        '>=' => '>='
    },
    :integer => {
      ':' => '=',
      '!' => '!=',
      '<' => '<',
      '<=' => '<=',
      '>' => '>',
      '>=' => '>='
    },
    :string => {
      ':' => 'LIKE',
      '!' => 'NOT LIKE',
    },
    :regex => {
      ':' => '~*',
      '!' => '!~*',
    },
  }

  # Currently unused
  @@term_to_left_join_map = {
  }

  # The parser
  @@parser = SearchParser.new

  # Runs the parser, transforms the raw output into an AST, then converts to SQL
  def initialize(query)
      @query = query
      @parse_tree = nil
      @left_joins = Set.new

      # Error output (nil if no error)
      @parse_error = nil

      # Parse the input into an AST
      begin
          @parse_tree = @@parser.parse(@query)
      rescue Parslet::ParseFailed => e
          @parse_error = e
          return
      end

      # Convert raw parse tree into an AST
      transform = Parslet::Transform.new do
        # Match literals
        rule(:string => simple(:s)) { NodeLiteral.new(s.to_s) }
        rule(:regex => simple(:r)) { NodeLiteral.new(r.to_s, true) }

        # Match singular queries (title searches without a key or operator)
        rule(:singular => simple(:s)) { NodePair.new(NodeKeyword.new('_'), NodeOperator.new(':'), s) }

        # Match pairs
        rule(:keyword => simple(:k), :operator => simple(:o), :values => simple(:v)) {
          NodePair.new(
            NodeKeyword.new(k.to_s), NodeOperator.new(o.to_s), v
          )
        }

        # Match brackets
        rule(:bracketed => simple(:b)) { NodeBracketed.new(b) }

        # Match value subtrees
        rule(:value_ands => simple(:a)) { NodeValueAnd.new([a]) }
        rule(:value_ands => sequence(:as)) { NodeValueAnd.new(as) }
        rule(:value_ors => simple(:o)) { NodeValueOr.new([o]) }
        rule(:value_ors => sequence(:os)) { NodeValueOr.new(os) }

        # Match negation
        rule(:negate => simple(:u)) { NodeNegate.new(u) }

        # Match conjunctions
        rule(:ands => simple(:a)) { NodeAnd.new([a]) }
        rule(:ands => sequence(:as)) { NodeAnd.new(as) }
        rule(:ors => simple(:o)) { NodeOr.new([o]) }
        rule(:ors => sequence(:os)) { NodeOr.new(os) }
      end

      # Generate SQL query and parameters from AST
      # This has the side effect of adding the SQL parameters to @where_values
      @where_values = []
      @where = transform.apply(@parse_tree).construct_clause(@where_values, fields)

      # TODO(plural): build in explicit support for requirements
      #   {is_banned,is_restricted,eternal_points,has_global_penalty,universal_faction_cost} all require restriction_id, would be good to have card_pool_id as well.
      # TODO(plural): build in explicit support for smart defaults, like restriction_id should imply is_banned = false.  card_pool_id should imply the latest restriction list.
  end

  # Accessors
  def parse_error
      return @parse_error
  end
  def where
      return @where
  end
  def where_values
      return @where_values
  end
  def left_joins
      return @left_joins.to_a
  end

  ############################################################################
  ## AST Nodes ###############################################################
  ############################################################################

  # Represents the context within a key:values pair
  # Types: string, string, bool, FieldData
  Context = Struct.new(:keyword, :operator, :negative_op, :field)

  NodeAnd = Struct.new(:children) do
    def construct_clause(parameters, fields)
      children.map { |c| c.construct_clause(parameters, fields) }.join(' AND ')
    end
  end

  NodeOr = Struct.new(:children) do
    def construct_clause(parameters, fields)
      children.map { |c| c.construct_clause(parameters, fields) }.join(' OR ')
    end
  end

  NodeNegate = Struct.new(:child) do
    def construct_clause(parameters, fields)
      'NOT ' + child.construct_clause(parameters, fields)
    end
  end

  NodeBracketed = Struct.new(:child) do
    def construct_clause(parameters, fields)
      bracs = child.instance_of?(NodeBracketed) ? '' : '()'
      bracs[0] + child.construct_clause(parameters, fields) + bracs[1]
    end
  end

  NodeKeyword = Struct.new(:name) do
    def construct_clause(parameters, fields)
      name
    end
  end

  NodeOperator = Struct.new(:operator) do
    def is_negative
      operator == '!'
    end
    def construct_clause(parameters, fields)
      operator
    end
  end

  NodePair = Struct.new(:keyword, :operator, :values) do
    def construct_clause(parameters, fields)
      # Determine the context of the query
      keyword_c = keyword.construct_clause(parameters, fields)
      context = Context.new(
        keyword_c,
        operator.construct_clause(parameters, fields),
        operator.is_negative,
        fields.find { |f| f.keywords.include?(keyword_c) }
      )

      # Check a field was found
      if context.field == nil
        raise 'Unknown keyword %s' % context.keyword
      end

      # Validate the operator (relies on strings and regexes having the same operators)
      if !@@operators[context.field.type].include?(context.operator)
        raise 'Invalid %s operator "%s"' % [context.field.type, context.operator]
      end

      # Construct the subtree within the new context
      values.construct_clause(parameters, context)
    end
  end

  NodeValueAnd = Struct.new(:children) do
    def construct_clause(parameters, context)
      bracs = children.length > 1 ? ['(', ')'] : ['', '']
      bracs[0] + children.map { |c| c.construct_clause(parameters, context) }.join(' and ') + bracs[1]
    end
  end

  NodeValueOr = Struct.new(:children) do
    def construct_clause(parameters, context)
      connector = context.negative_op ? ' and ' : ' or '
      bracs = children.length > 1 ? ['(', ')'] : ['', '']
      bracs[0] + children.map { |c| c.construct_clause(parameters, context) }.join(connector) + bracs[1]
    end
  end

  NodeLiteral = Struct.new(:value, :is_regex) do
    def construct_clause(parameters, context)
      # Only accept regex values for string fields
      if context.field.type != :string and is_regex != nil
        raise '%s field does not accept regular expressions but was passed %s' % [context.field.type, value]
      end

      # Determine the operator (manually catch regexes)
      sql_operator = @@operators[is_regex ? :regex : context.field.type][context.operator]

      # Format as appropriate for the query type
      case context.field.type

      # Arrays
      when :array
        if value.match?(/\A(\w+)-(\d+)\Z/i)
          value.gsub!('-', '=')
        end
        parameters << value
        return '%s (? = ANY(%s))' % [sql_operator, context.field.sql]

      # Booleans
      when :boolean
        if !['true', 'false', 't', 'f', '1', '0'].include?(value)
          raise 'Invalid value "%s" for boolean field "%s"' % [value, context.keyword]
        end
        parameters << value
        return '%s %s ?' % [context.field.sql, sql_operator]

      # Dates
      when :date
        value.downcase!
        if ['now'].include?(value)
          @value = Time.now.strftime("%Y-%m-%d")
        elsif !value.match?(/\d{4}-\d{2}-\d{2}|\d{8}/)
          raise 'Invalid value "%s" for date field "%s" - only YYYY-MM-DD or YYYYMMDD are supported.' % [value, context.keyword]
        end
        parameters << value
        return '%s %s ?' % [context.field.sql, sql_operator]

      # Integers
      when :integer
        if !value.match?(/\A(\d+|x)\Z/i)
          raise 'Invalid value "%s" for integer field "%s"' % [value, context.keyword]
        end
        parameters << (value.downcase == 'x' ? -1 : value)
        return '%s %s ?' % [context.field.sql, sql_operator]

      # Strings
      when :string
        if is_regex
          parameters << "%s" % value
        else
          parameters << '%%%s%%' % value.downcase
        end
        return 'lower(%s) %s ?' % [context.field.sql, sql_operator]

      # Error
      else
        raise 'Unknown query type "%s"' %  context.field.type
      end
    end
  end
end
