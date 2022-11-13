# TODO(plural): Add attribution to cards.
class CardSearchQueryBuilder

    # :type is one of :array, :boolean, :integer, :string
    FieldData = Struct.new(:type, :sql, :keywords)

    # TODO(plural): figure out how to do name matches that are LIKEs over elements of an array.
    # format should implicitly use the currently active card pool and restriction lists unless another is specified.
    @@fields = [
      FieldData.new(:array, 'unified_cards.card_cycle_ids', ['card_cycle']),
      FieldData.new(:array, 'unified_cards.card_pool_ids', ['card_pool']),
      FieldData.new(:array, 'unified_cards.card_set_ids', ['card_set']),
      FieldData.new(:array, 'unified_cards.lower_card_subtype_names', ['card_subtype']),
      FieldData.new(:array, 'unified_cards.card_subtype_ids', ['card_subtype_id']),
      FieldData.new(:array, 'unified_cards.restrictions_points', ['eternal_points']),
      FieldData.new(:array, 'unified_cards.format_ids', ['format']),
      FieldData.new(:array, 'unified_cards.restrictions_global_penalty', ['has_global_penalty']),
      FieldData.new(:array, 'unified_cards.restrictions_banned', ['is_banned']),
      FieldData.new(:array, 'unified_cards.restrictions_restricted', ['is_restricted']),
      FieldData.new(:array, 'unified_cards.printing_ids', ['printing_id']),
      FieldData.new(:array, 'unified_cards.restriction_ids', ['restriction_id']),
      FieldData.new(:array, 'unified_cards.snapshot_ids', ['snapshot']),
      FieldData.new(:array, 'unified_cards.restrictions_universal_faction_cost', ['universal_faction_cost']),
      FieldData.new(:boolean, 'unified_cards.additional_cost', ['additional_cost']),
      FieldData.new(:boolean, 'unified_cards.advanceable', ['advanceable']),
      FieldData.new(:boolean, 'unified_cards.gains_subroutines', ['gains_subroutines']),
      FieldData.new(:boolean, 'unified_cards.in_restriction', ['in_restriction']),
      FieldData.new(:boolean, 'unified_cards.interrupt', ['interrupt']),
      FieldData.new(:boolean, 'unified_cards.is_unique', ['is_unique']),
      FieldData.new(:boolean, 'unified_cards.on_encounter_effect', ['on_encounter_effect']),
      FieldData.new(:boolean, 'unified_cards.performs_trace', ['performs_trace']),
      FieldData.new(:boolean, 'unified_cards.trash_ability', ['trash_ability']),
      FieldData.new(:integer, 'unified_cards.advancement_requirement', ['advancement_cost']),
      FieldData.new(:integer, 'unified_cards.agenda_points', ['agenda_points']),
      FieldData.new(:integer, 'unified_cards.base_link', ['base_link']),
      FieldData.new(:integer, 'unified_cards.cost', ['cost']),
      FieldData.new(:integer, 'unified_cards.influence_cost', ['influence_cost']),
      FieldData.new(:integer, 'unified_cards.link_provided', ['link_provided']),
      FieldData.new(:integer, 'unified_cards.memory_cost', ['memory_usage']),
      FieldData.new(:integer, 'unified_cards.mu_provided', ['mu_provided']),
      FieldData.new(:integer, 'unified_cards.num_printed_subroutines', ['num_printed_subroutines']),
      FieldData.new(:integer, 'unified_cards.num_printings', ['num_printings']),
      FieldData.new(:integer, 'unified_cards.recurring_credits_provided', ['recurring_credits_provided']),
      FieldData.new(:integer, 'unified_cards.strength', ['strength']),
      FieldData.new(:integer, 'unified_cards.trash_cost', ['trash_cost']),
      FieldData.new(:string, 'unified_cards.attribution', ['attribution']),
      FieldData.new(:string, 'unified_cards.card_type_id', ['card_type', 't']),
      FieldData.new(:string, 'unified_cards.faction_id', ['faction', 'f']),
      FieldData.new(:string, 'unified_cards.side_id', ['side', 'd']),
      FieldData.new(:string, 'unified_cards.stripped_text', ['text', 'x']),
      FieldData.new(:string, 'unified_cards.stripped_title', ['title', '_'])
    ]
    @@operators = {
      :array => {
        ':' => '',
        '!' => 'NOT',
      },
      :boolean => {
        ':' => '=',
        '!' => '!=',
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

    @@parser = CardSearchParser.new

    @@term_to_left_join_map = {
    }

    # Represents the context within a key:values pair
    # Types: string, string, bool, FieldData
    Context = Struct.new(:keyword, :operator, :negative_op, :field)

    NodeAnd = Struct.new(:children) do
      def construct_clause(parameters)
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause(parameters) }.join(' and ') + bracs[1]
      end
    end

    NodeOr = Struct.new(:children) do
      def construct_clause(parameters)
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause(parameters) }.join(' or ') + bracs[1]
      end
    end

    NodeNegate = Struct.new(:child) do
      def construct_clause(parameters)
        'not ' + child.construct_clause(parameters)
      end
    end

    NodeKeyword = Struct.new(:name) do
      def construct_clause(parameters)
        name
      end
    end

    NodeOperator = Struct.new(:operator) do
      def is_negative
        operator == '!'
      end
      def construct_clause(parameters)
        operator
      end
    end

    NodePair = Struct.new(:keyword, :operator, :values) do
      def construct_clause(parameters)
        # Determine the context of the query
        keyword_c = keyword.construct_clause(parameters)
        context = Context.new(
          keyword_c,
          operator.construct_clause(parameters),
          operator.is_negative,
          @@fields.find { |f| f.keywords.include?(keyword_c) }
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

    def initialize(query)
        @query = query
        @parse_tree = nil
        @left_joins = Set.new

        # Output
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
        @where = transform.apply(@parse_tree).construct_clause(@where_values)

        # TODO(plural): build in explicit support for requirements
        #   {is_banned,is_restricted,eternal_points,has_global_penalty,universal_faction_cost} all require restriction_id, would be good to have card_pool_id as well.
        # TODO(plural): build in explicit support for smart defaults, like restriction_id should imply is_banned = false.  card_pool_id should imply the latest restriction list.
    end
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
end
