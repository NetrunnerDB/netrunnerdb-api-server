# TODO(plural): Add attribution to cards.
class CardSearchQueryBuilder
    @@parser = CardSearchParser.new
    @@array_keywords = [
        'card_cycle',
        'card_pool',
        'card_set',
        'card_subtype',
        'card_subtype_id',
        'eternal_points',
        'format',
        'has_global_penalty',
        'is_banned',
        'is_restricted',
        'printing_id',
        'restriction_id',
        's',
        'snapshot',
        'universal_faction_cost',
    ]
    @@boolean_keywords = [
        'additional_cost',
        'advanceable',
        'b',
        'banlist',
        'gains_subroutines',
        'in_restriction',
        'interrupt',
        'is_unique',
        'on_encounter_effect',
        'performs_trace',
        'trash_ability',
        'u',
    ]
    @@numeric_keywords = [
        'advancement_cost',
        'agenda_points',
        'base_link',
        'cost',
        'g',
        'h',
        'influence_cost',
        'l',
        'link_provided',
        'm',
        'memory_usage',
        'mu_provided',
        'n',
        'num_printed_subroutines',
        'num_printings',
        'o',
        'p',
        'recurring_credits_provided',
        'strength',
        'trash_cost',
        'v',
    ]
    @@string_keywords = [
        '_',
        'attribution',
        'card_type',
        'd',
        'f',
        'faction',
        'side',
        't',
        'text',
        'title',
        'x',
    ]
    # TODO(plural): figure out how to do name matches that are LIKEs over elements of an array.
    @@term_to_field_map = {
        # format should implicitly use the currently active card pool and restriction lists unless another is specified.
        '_' => 'unified_cards.stripped_title',
        'additional_cost' => 'unified_cards.additional_cost',
        'advanceable' => 'unified_cards.advanceable',
        'advancement_cost' => 'unified_cards.advancement_requirement',
        'agenda_points' => 'unified_cards.agenda_points',
        'attribution' => 'unified_cards.attribution',
        'base_link' => 'unified_cards.base_link',
        'card_cycle' => 'unified_cards.card_cycle_ids',
        'card_pool' => 'unified_cards.card_pool_ids',
        'card_set' => 'unified_cards.card_set_ids',
        'card_subtype' => 'unified_cards.lower_card_subtype_names',
        'card_subtype_id' => 'unified_cards.card_subtype_ids',
        'card_type' => 'unified_cards.card_type_id',
        'cost' => 'unified_cards.cost',
        'd' => 'unified_cards.side_id',
        'eternal_points' => 'unified_cards.restrictions_points',
        'f' => 'unified_cards.faction_id',
        'faction' => 'unified_cards.faction_id',
        'format' => 'unified_cards.format_ids',
        'g' => 'unified_cards.advancement_requirement',
        'gains_subroutines' => 'unified_cards.gains_subroutines',
        'h' => 'unified_cards.trash_cost',
        'has_global_penalty' => 'unified_cards.restrictions_global_penalty',
        'in_restriction' => 'unified_cards.in_restriction',
        'influence_cost' => 'unified_cards.influence_cost',
        'interrupt' => 'unified_cards.interrupt',
        'is_banned' => 'unified_cards.restrictions_banned',
        'is_restricted' => 'unified_cards.restrictions_restricted',
        'is_unique' => 'unified_cards.is_unique',
        'l' => 'unified_cards.base_link',
        'link_provided' => 'unified_cards.link_provided',
        'm' => 'unified_cards.memory_cost',
        'memory_usage' => 'unified_cards.memory_cost',
        'mu_provided' => 'unified_cards.mu_provided',
        'n' => 'unified_cards.influence_cost',
        'num_printed_subroutines' => 'unified_cards.num_printed_subroutines',
        'num_printings' => 'unified_cards.num_printings',
        'o' => 'unified_cards.cost',
        'on_encounter_effect' => 'unified_cards.on_encounter_effect',
        'p' => 'unified_cards.strength',
        'performs_trace' => 'unified_cards.performs_trace',
        'printing_id' => 'unified_cards.printing_ids',
        'recurring_credits_provided' => 'unified_cards.recurring_credits_provided',
        'restriction_id' => 'unified_cards.restriction_ids',
        's' => 'unified_cards.lower_card_subtype_names',
        'side' => 'unified_cards.side_id',
        'snapshot' => 'unified_cards.snapshot_ids',
        'strength' => 'unified_cards.strength',
        't' => 'unified_cards.card_type_id',
        'text' => 'unified_cards.stripped_text',
        'title' => 'unified_cards.stripped_title',
        'trash_ability' => 'unified_cards.trash_ability',
        'trash_cost' => 'unified_cards.trash_cost',
        'u' => 'unified_cards.is_unique',
        'universal_faction_cost' => 'unified_cards.restrictions_universal_faction_cost',
        'v' => 'unified_cards.agenda_points',
        'x' => 'unified_cards.stripped_text',
    }

    @@term_to_left_join_map = {
    }

    @@array_operators = {
        ':' => '',
        '!' => 'NOT',
    }
    @@boolean_operators = {
        ':' => '=',
        '!' => '!=',
    }
    @@numeric_operators = {
        ':' => '=',
        '!' => '!=',
        '<' => '<',
        '<=' => '<=',
        '>' => '>',
        '>=' => '>='
    }
    @@string_operators = {
        ':' => 'LIKE',
        '!' => 'NOT LIKE',
    }
    @@regex_operators = {
        ':' => '~*',
        '!' => '!~*',
    }

    class Node < Struct
      def construct_clause
        raise 'construct_clause not implemented in ' + self.class.name
      end
    end

    NodeAnd = Node.new(:children) do
      def construct_clause
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause }.join(' and ') + bracs[1]
      end
    end

    NodeOr = Node.new(:children) do
      def construct_clause
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause }.join(' or ') + bracs[1]
      end
    end

    NodeNegate = Node.new(:child) do
      def construct_clause
        'not ' + child.construct_clause
      end
    end

    NodeKeyword = Node.new(:name) do
      def construct_clause
        name
      end
    end

    NodeOperator = Node.new(:operator) do
      def is_negative
        operator == '!'
      end
      def construct_clause
        operator
      end
    end

    NodePair = Node.new(:keyword, :operator, :values) do
      def construct_clause
        raw_operator = operator.construct_clause

        # Determine the type of query and update the global context
        @@keyword = keyword.construct_clause
        @@negative_op = operator.is_negative
        @@query_type = ''
        if @@array_keywords.include?(keyword)
          @@query_type = 'Array'
          if @@array_operators.include?(raw_operator)
            @@operator = @@array_operators[raw_operator]
          else
            raise 'Invalid array operator "%s"' % operator
          end
        elsif @@boolean_keywords.include?(keyword)
          @@query_type = 'Boolean'
          if @@boolean_operators.include?(raw_operator)
            @@operator = @@boolean_operators[raw_operator]
          else
            raise 'Invalid boolean operator "%s"' % operator
          end
        elsif @@numeric_keywords.include?(keyword)
          @@query_type = 'Integer'
          if @@numeric_operators.include?(raw_operator)
            @@operator = @@numeric_operators[raw_operator]
          else
            raise 'Invalid integer operator "%s"' % operator
          end
        else
          @@query_type = 'String'
          if @@string_operators.include?(raw_operator)
            @@operator = @@string_operators[raw_operator]
          else
            raise 'Invalid string operator "%s"' % operator
          end
        end

        # Construct the subtree within the new context
        values.construct_clause
      end
    end

    NodeValueAnd = Node.new(:children) do
      def construct_clause
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause }.join(' and ') + bracs[1]
      end
    end

    NodeValueOr = Node.new(:children) do
      def construct_clause
        connector = @@negative_op ? ' and ' : ' or '
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause }.join(connector) + bracs[1]
      end
    end

    NodeLiteral = Node.new(:value, :is_regex) do
      def construct_clause
        # Only accept regex values for string fields
        if @@query_type != 'String' and is_regex != nil
          raise '%s field does not accept regular expressions but was passed %s' % [@@query_type, value]
        end

        # Format as appropriate for the query type
        case @@query_type

        # Arrays
        when 'Array'
          if value.match?(/\A(\w+)-(\d+)\Z/i)
            value.gsub!('-', '=')
          end
          @@parameters << value
          return '%s (? = ANY(%s))' % [@@operator, @@term_to_field_map[@@keyword]]

        # Booleans
        when 'Boolean'
          if !['true', 'false', 't', 'f', '1', '0'].include?(value)
            raise 'Invalid value "%s" for boolean field "%s"' % [value, @@keyword]
          end
          @@parameters << value
          return '%s %s ?' % [@@term_to_field_map[@@keyword], @@operator]

        # Integers
        when 'Integer'
          if !value.match?(/\A(\d+|x)\Z/i)
            raise 'Invalid value "%s" for integer field "%s"' % [value, @@keyword]
          end
          @@parameters << value.downcase == 'x' ? -1 : value
          return '%s %s ?' % [@@term_to_field_map[@@keyword], @@operator]

        # Strings
        when 'String'
          if is_regex
            @@parameters << "%s" % value
          else
            @@parameters << '%%%s%%' % value.downcase
          end
          return 'lower(%s) %s ?' % [@@term_to_field_map[@@keyword], @@operator]

        # Error
        else
          raise 'Unknown query type "%s"' %  @@query_type
        end
      end
    end

    def initialize(query)
        @query = query
        @parse_tree = nil
        @left_joins = Set.new

        # AST context variables
        # This context is set for each pair node
        # Since pairs aren't recursive it's safe to reset these values each time
        @@keyword = ''
        @@operator = ''
        @@negative_op = false
        @@query_type = ''

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
        # Note: this has the side effect of adding the query parameters to
        # @@parameters
        @@parameters = []
        @where = transform.apply(@parse_tree).construct_clause
        @where_values = @@parameters

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
        return @@parameters
    end
    def left_joins
        return @left_joins.to_a
    end
end
