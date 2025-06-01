# frozen_string_literal: true

require 'rails_helper'
require 'parslet/convenience'

RSpec.describe CardSearchQueryBuilder do
  describe '#initialize' do
    context 'with simple successful query' do
      let(:builder) { described_class.new('x:trash') }

      it 'parses without error' do
        expect(builder.parse_error).to be_nil
      end

      it 'builds correct where clause' do
        expect(builder.where).to eq('lower(unified_cards.stripped_text) LIKE ?')
        expect(builder.where_values).to eq(['%trash%'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with multiple terms' do
      let(:builder) { described_class.new('x:trash cost:3') }

      it 'parses without error' do
        expect(builder.parse_error).to be_nil
      end

      it 'builds correct where clause' do
        expect(builder.where).to eq('lower(unified_cards.stripped_text) LIKE ? AND unified_cards.cost = ?')
        expect(builder.where_values).to eq(['%trash%', '3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with numeric field not equal' do
      let(:builder) { described_class.new('trash_cost!3') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('unified_cards.trash_cost != ?')
        expect(builder.where_values).to eq(['3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with numeric field less than' do
      let(:builder) { described_class.new('trash_cost<3') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('unified_cards.trash_cost < ?')
        expect(builder.where_values).to eq(['3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with numeric field less than or equal to' do
      let(:builder) { described_class.new('trash_cost<=3') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('unified_cards.trash_cost <= ?')
        expect(builder.where_values).to eq(['3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with numeric field greater than' do
      let(:builder) { described_class.new('trash_cost>3') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('unified_cards.trash_cost > ?')
        expect(builder.where_values).to eq(['3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with numeric field greater than or equal to' do
      let(:builder) { described_class.new('trash_cost>=3') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('unified_cards.trash_cost >= ?')
        expect(builder.where_values).to eq(['3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with string field not like' do
      let(:builder) { described_class.new('title!sure') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('lower(unified_cards.stripped_title) NOT LIKE ?')
        expect(builder.where_values).to eq(['%sure%'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with bad boolean operators' do
      ['<', '<=', '>', '>='].each do |op|
        it "raises error for operator #{op}" do
          expect do
            described_class.new("is_unique#{op}true")
          end.to raise_error(RuntimeError, "Invalid boolean operator \"#{op}\"")
        end
      end
    end

    context 'with bad string operators' do
      ['<', '<=', '>', '>='].each do |op|
        it "raises error for operator #{op}" do
          expect do
            described_class.new("title#{op}sure")
          end.to raise_error(RuntimeError, "Invalid string operator \"#{op}\"")
        end
      end
    end

    context 'with bare word' do
      let(:builder) { described_class.new('diversion') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('lower(unified_cards.stripped_title) LIKE ?')
        expect(builder.where_values).to eq(['%diversion%'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with bare word negated' do
      let(:builder) { described_class.new('!diversion') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('NOT lower(unified_cards.stripped_title) LIKE ?')
        expect(builder.where_values).to eq(['%diversion%'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with quoted string negated' do
      let(:builder) { described_class.new('!"diversion of funds"') }

      it 'builds correct where clause' do
        expect(builder.where).to eq('NOT lower(unified_cards.stripped_title) LIKE ?')
        expect(builder.where_values).to eq(['%diversion of funds%'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with unicode in query' do
      let(:builder) { described_class.new('"Chaos Theory: Wünderkind"') }

      it 'strips unicode for query' do
        expect(builder.where).to eq('lower(unified_cards.stripped_title) LIKE ?')
        expect(builder.where_values).to eq(['%chaos theory: wunderkind%'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with bad query operator' do
      it 'raises error for unknown keyword' do
        expect do
          described_class.new('asdfasdf:bleargh')
        end.to raise_error(RuntimeError, 'Unknown keyword asdfasdf')
      end
    end

    context 'with is_banned and no restriction specified' do
      let(:builder) { described_class.new('is_banned:true') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_banned))')
        expect(builder.where_values).to eq(['true'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with is_restricted and no restriction specified' do
      let(:builder) { described_class.new('is_restricted:true') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_restricted))')
        expect(builder.where_values).to eq(['true'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with has_global_penalty and no restriction specified' do
      let(:builder) { described_class.new('has_global_penalty:true') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_global_penalty))')
        expect(builder.where_values).to eq(['true'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with is_banned and restriction specified' do
      let(:builder) { described_class.new('is_banned:true restriction_id:ban_list_foo') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_banned)) AND  (? = ANY(unified_cards.restriction_ids))') # rubocop:disable Layout/LineLength
        expect(builder.where_values).to eq(%w[true ban_list_foo])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with is_restricted and restriction specified' do
      let(:builder) { described_class.new('is_restricted:true restriction_id:ban_list_foo') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_restricted)) AND  (? = ANY(unified_cards.restriction_ids))') # rubocop:disable Layout/LineLength
        expect(builder.where_values).to eq(%w[true ban_list_foo])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with has_global_penalty and restriction specified' do
      let(:builder) { described_class.new('has_global_penalty:true restriction_id:ban_list_foo') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_global_penalty)) AND  (? = ANY(unified_cards.restriction_ids))') # rubocop:disable Layout/LineLength
        expect(builder.where_values).to eq(%w[true ban_list_foo])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with eternal_points' do
      let(:builder) { described_class.new('eternal_points:eternal_restriction_id-3') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_points))')
        expect(builder.where_values).to eq(['eternal_restriction_id=3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with universal_faction_cost' do
      let(:builder) { described_class.new('universal_faction_cost:3') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.restrictions_universal_faction_cost))')
        expect(builder.where_values).to eq(['3'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with card_pool' do
      let(:builder) { described_class.new('card_pool:best_pool') }

      it 'builds correct where clause' do
        expect(builder.where.strip).to eq('(? = ANY(unified_cards.card_pool_ids))')
        expect(builder.where_values).to eq(['best_pool'])
        expect(builder.left_joins).to eq([])
      end
    end

    context 'with bad boolean value' do
      it 'raises error for invalid boolean value' do
        expect do
          described_class.new('additional_cost:nah')
        end.to raise_error(RuntimeError, 'Invalid value "nah" for boolean field "additional_cost"')
      end
    end

    context 'with bad numeric value' do
      it 'raises error for invalid integer value' do
        expect do
          described_class.new('trash_cost:"too damn high"')
        end.to raise_error(RuntimeError, 'Invalid value "too damn high" for integer field "trash_cost"')
      end
    end
  end
end
