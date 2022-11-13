class SearchQueryBuilder

  # A struct for representing an accepted field and its properties
  # :type is one of :array, :boolean, :date, :integer, :string
  FieldData = Struct.new(:type, :sql, :keywords)

  # Override this in child classes to define the valid fields for each builder
  @fields = []

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
      bracs = children.length > 1 ? ['(', ')'] : ['', '']
      bracs[0] + children.map { |c| c.construct_clause(parameters, fields) }.join(' and ') + bracs[1]
    end
  end

  NodeOr = Struct.new(:children) do
    def construct_clause(parameters, fields)
      bracs = children.length > 1 ? ['(', ')'] : ['', '']
      bracs[0] + children.map { |c| c.construct_clause(parameters, fields) }.join(' or ') + bracs[1]
    end
  end

  NodeNegate = Struct.new(:child) do
    def construct_clause(parameters, fields)
      'not ' + child.construct_clause(parameters, fields)
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
        if ['now'].include?(value.downcase)
          @value = Time.now.strftime("%Y-%m-%d")
        elsif !value.match?(/\d\d\d\d-\d\d-\d\d/)
          raise 'Invalid date format for field %s - expected YYYY-MM-DD but got %s' % [context.keyword, value]
        end
        parameters << value
        return '%s %s ?' % [context.field.sql, sql_operator]

      # Integers
      when :integer
        if !value.match?(/\A(\d+|x)\Z/i)
          raise 'Invalid value "%s" for integer field "%s"' % [value, context.keyword]
        end
        parameters << value.downcase == 'x' ? -1 : value
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
