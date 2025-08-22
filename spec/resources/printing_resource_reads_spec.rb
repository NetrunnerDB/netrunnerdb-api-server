# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrintingResource, type: :resource do
  describe 'serialization' do
    let!(:printing) { Printing.find('01065') }

    it 'works' do
      params[:filter] = { id: { eq: printing.id } }
      render

      data = jsonapi_data[0]
      expect(data.rawid).to eq(printing.id)
      expect(data.card_id).to eq(printing.card_id)
      expect(data.card_cycle_id).to eq(printing.card_cycle_id)
      expect(data.card_cycle_name).to eq(printing.card_cycle_name)
      expect(data.card_set_id).to eq(printing.card_set_id)
      expect(data.card_set_name).to eq(printing.card_set_name)
      expect(data.flavor).to eq(printing.flavor)
      expect(data.display_illustrators).to eq(printing.display_illustrators)
      expect(data.illustrator_ids).to eq(printing.illustrator_ids)
      expect(data.illustrator_names).to eq(printing.illustrator_names)
      expect(data.position).to eq(printing.position)
      expect(data.position_in_set).to eq(printing.position_in_set)
      expect(data.quantity).to eq(printing.quantity)
      expect(data.date_release).to eq(printing.date_release.strftime('%Y-%m-%d'))
      expect(data.updated_at).to eq(printing.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.stripped_title).to eq(printing.stripped_title)
      expect(data.title).to eq(printing.title)
      expect(data.card_type_id).to eq(printing.card_type_id)
      expect(data.side_id).to eq(printing.side_id)
      expect(data.faction_id).to eq(printing.faction_id)
      expect(data.advancement_requirement).to eq(printing.advancement_requirement)
      expect(data.agenda_points).to eq(printing.agenda_points)
      expect(data.base_link).to eq(printing.base_link)
      expect(data.cost).to eq(printing.cost.to_s)
      expect(data.deck_limit).to eq(printing.deck_limit)
      expect(data.in_restriction).to eq(printing.in_restriction)
      expect(data.influence_cost).to eq(printing.influence_cost)
      expect(data.influence_limit).to eq(printing.influence_limit)
      expect(data.memory_cost).to eq(printing.memory_cost)
      expect(data.minimum_deck_size).to eq(printing.minimum_deck_size)
      expect(data.num_printings).to eq(printing.num_printings)
      expect(data.is_latest_printing).to eq(printing.is_latest_printing)
      expect(data.printing_ids).to eq(printing.printing_ids)
      expect(data.restriction_ids).to eq(printing.restriction_ids)
      expect(data.strength).to eq(printing.strength)
      expect(data.stripped_text).to eq(printing.stripped_text)
      expect(data.text).to eq(printing.text)
      expect(data.trash_cost).to eq(printing.trash_cost)
      expect(data.is_unique).to eq(printing.is_unique)
      expect(data.card_subtype_ids).to eq(printing.card_subtype_ids)
      expect(data.card_subtype_names).to eq(printing.card_subtype_names)
      expect(data.display_subtypes).to eq(printing.display_subtypes)
      expect(data.attribution).to eq(printing.attribution)
      expect(data.format_ids).to eq(printing.format_ids)
      expect(data.card_pool_ids).to eq(printing.card_pool_ids)
      expect(data.snapshot_ids).to eq(printing.snapshot_ids)
      expect(data.card_cycle_ids).to eq(printing.card_cycle_ids)
      expect(data.card_set_ids).to eq(printing.card_set_ids)
      expect(data.designed_by).to eq(printing.designed_by)
      expect(data.released_by).to eq(printing.released_by)
      expect(data.printings_released_by).to eq(printing.printings_released_by)
      expect(data.pronouns).to eq(printing.pronouns)
      expect(data.pronunciation_approximation).to eq(printing.pronunciation_approximation)
      expect(data.pronunciation_ipa).to eq(printing.pronunciation_ipa)
      expect(data.images).not_to be_nil
      expect(data.card_abilities).to eq(printing.card_abilities.stringify_keys)
      expect(data.latest_printing_id).to eq(printing.latest_printing_id)
      expect(data.restrictions).to eq(printing.restrictions.stringify_keys)
    end
  end

  describe 'flip_card' do
    let!(:printing) { Printing.find('01072') }

    it 'works' do
      params[:filter] = { id: { eq: printing.id } }
      render

      data = jsonapi_data[0]
      expect(data.num_extra_faces).to eq(printing.num_extra_faces)
      expect(data.faces[0][:display_subtypes]).to eq(printing.faces_display_subtypes[0])
      expect(data.faces[0][:flavor]).to eq(printing.faces_flavor[0])
      expect(data.faces[0][:copy_quantity]).to eq(printing.faces_copy_quantity[0])
    end
  end

  describe 'has xlarge image' do
    let!(:printing) { Printing.find('01072') }  # Hoshiko

    it 'has xlarge image' do
      params[:filter] = { id: { eq: printing.id } }
      render

      data = jsonapi_data[0]
      expect(data.images[:nrdb_classic][:xlarge]).to eq("https://card-images.netrunnerdb.com/v2/xlarge/#{printing.id}.webp")
      expect(data.faces[0][:images][:nrdb_classic][:xlarge]).to eq("https://card-images.netrunnerdb.com/v2/xlarge/#{printing.id}-0.webp")
    end
  end

  describe 'no xlarge image' do
    let!(:printing) { Printing.find('01056') }  # Adonis Campaign

    it 'no xlarge image' do
      params[:filter] = { id: { eq: printing.id } }
      render

      data = jsonapi_data[0]
      expect(data.images[:nrdb_classic][:xlarge]).to be_falsy
    end
  end

  describe 'filtering' do
    let!(:printing) { Printing.find('21180') }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: printing.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:rawid)).to eq([printing.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(printing_id, include_value, resource_type, id)
      params[:filter] = { id: { eq: printing_id } }
      params[:include] = include_value
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.rawid }
      expect(ids).to include(id)
    end

    describe 'include card' do
      let!(:printing) { Printing.find('21166') }
      let!(:card) { Card.find('steelskin_scarring') }

      it 'works' do
        check_included_for_id(printing.id, 'card', 'cards', card.id)
      end
    end

    describe 'include card cycles' do
      let!(:printing) { Printing.find('21166') }
      let!(:printing_cycle) { CardCycle.find('borealis') }

      it 'works' do
        check_included_for_id(printing.id, 'card_cycle', 'card_cycles', printing_cycle.id)
      end
    end

    describe 'include card set' do
      let!(:printing) { Printing.find('21166') }
      let!(:card_set) { CardSet.find('midnight_sun') }

      it 'works' do
        check_included_for_id(printing.id, 'card_set', 'card_sets', card_set.id)
      end
    end

    describe 'include card subtypes' do
      let!(:printing) { Printing.find('01056') }
      let!(:card_subtype) { CardSubtype.find('advertisement') }

      it 'works' do
        check_included_for_id(printing.id, 'card_subtypes', 'card_subtypes', card_subtype.id)
      end
    end

    describe 'include card type' do
      let!(:printing) { Printing.find('21162') }
      let!(:card_type) { CardType.find('agenda') }

      it 'works' do
        check_included_for_id(printing.id, 'card_type', 'card_types', card_type.id)
      end
    end

    describe 'include faction' do
      let!(:printing) { Printing.find('21167') }
      let!(:faction) { Faction.find('weyland_consortium') }

      it 'works' do
        check_included_for_id(printing.id, 'faction', 'factions', faction.id)
      end
    end

    describe 'include illustrators' do
      let!(:printing) { Printing.find('01050') }
      let!(:illustrator) { Illustrator.find('ann_illustrator') }

      it 'works' do
        check_included_for_id(printing.id, 'illustrators', 'illustrators', illustrator.id)
      end
    end

    describe 'include side' do
      let!(:printing) { Printing.find('21181') }
      let!(:side) { Side.find('corp') }

      it 'works' do
        check_included_for_id(printing.id, 'side', 'sides', side.id)
      end
    end

    describe 'include card_pools' do
      let!(:printing) { Printing.find(Card.find('border_control').latest_printing_id) }
      let!(:card_pool) { CardPool.find('eternal_01') }

      it 'works' do
        check_included_for_id(printing.id, 'card_pools', 'card_pools', card_pool.id)
      end
    end
  end
end
