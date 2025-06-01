# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeckValidation do
  let(:empty_validation) { { 'label' => 'empty' } }
  let(:snapshot_only) { { 'label' => 'expand snapshot', 'snapshot_id' => 'standard_02' } }
  let(:format_only) { { 'label' => 'expand format', 'format_id' => 'standard' } }
  let(:card_pool_only) { { 'label' => 'expand card_pool', 'card_pool_id' => 'startup_02' } }
  let(:restriction_only) { { 'label' => 'expand restriction', 'restriction_id' => 'standard_banlist' } }

  describe '#initialize' do
    context 'with empty validation' do
      subject(:v) { described_class.new(empty_validation) }

      it 'has expected fields' do
        expect(v.label).to eq('empty')
        expect(v.format_id).to be_nil
        expect(v.card_pool_id).to be_nil
        expect(v.restriction_id).to be_nil
        expect(v.snapshot_id).to be_nil
        expect(v).to be_valid
      end
    end

    context 'with snapshot only' do
      subject(:v) { described_class.new(snapshot_only) }

      it 'expands fields' do
        expect(v.label).to eq('expand snapshot')
        expect(v.format_id).to eq('standard')
        expect(v.card_pool_id).to eq('standard_02')
        expect(v.restriction_id).to eq('standard_banlist')
        expect(v.snapshot_id).to eq('standard_02')
        expect(v).to be_valid
      end
    end

    context 'with format only' do
      subject(:v) { described_class.new(format_only) }

      it 'expands fields' do
        expect(v.label).to eq('expand format')
        expect(v.format_id).to eq('standard')
        expect(v.card_pool_id).to eq('standard_02')
        expect(v.restriction_id).to eq('standard_banlist')
        expect(v.snapshot_id).to eq('standard_02')
        expect(v).to be_valid
      end
    end

    context 'with card pool only' do
      subject(:v) { described_class.new(card_pool_only) }

      it 'expands fields' do
        expect(v.label).to eq('expand card_pool')
        expect(v.format_id).to eq('startup')
        expect(v.card_pool_id).to eq('startup_02')
        expect(v.restriction_id).to be_nil
        expect(v.snapshot_id).to be_nil
        expect(v).to be_valid
      end
    end

    context 'with restriction only' do
      subject(:v) { described_class.new(restriction_only) }

      it 'expands fields' do
        expect(v.label).to eq('expand restriction')
        expect(v.format_id).to eq('standard')
        expect(v.restriction_id).to eq('standard_banlist')
        expect(v.card_pool_id).to be_nil
        expect(v.snapshot_id).to be_nil
        expect(v).to be_valid
      end
    end
  end
end
