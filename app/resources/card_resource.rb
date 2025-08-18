# frozen_string_literal: true

# Public resource for Card objects.
class CardResource < ApplicationResource # rubocop:disable Metrics/ClassLength
  primary_endpoint '/cards', %i[index show]

  self.default_page_size = 1000
  self.max_page_size = 10_000

  attribute :id, :string
  attribute :stripped_title, :string
  attribute :title, :string
  attribute :card_type_id, :string
  attribute :side_id, :string
  attribute :faction_id, :string
  # TODO(plural): Move cost and agenda requirements into model.
  attribute :cost, :string do
    @object.cost == -1 ? 'X' : @object.cost
  end
  attribute :advancement_requirement, :string do
    @object.advancement_requirement == -1 ? 'X' : @object.advancement_requirement
  end
  attribute :agenda_points, :integer
  attribute :base_link, :integer
  attribute :deck_limit, :integer
  attribute :in_restriction, :boolean
  attribute :influence_cost, :integer
  attribute :influence_limit, :integer
  attribute :memory_cost, :integer
  attribute :minimum_deck_size, :integer
  attribute :num_printings, :integer
  attribute :printing_ids, :array_of_strings do
    @object.printing_ids_in_database
  end
  attribute :date_release, :date
  attribute :restriction_ids, :array_of_strings
  attribute :strength, :integer
  attribute :stripped_text, :string
  attribute :text, :string
  attribute :trash_cost, :integer
  attribute :is_unique, :boolean
  attribute :card_subtype_ids, :array_of_strings do
    @object.card_subtype_ids_in_database
  end
  attribute :display_subtypes, :string
  attribute :attribution, :string
  attribute :updated_at, :datetime
  attribute :format_ids, :array_of_strings
  attribute :card_pool_ids, :array_of_strings do
    @object.card_pool_ids_in_database
  end
  attribute :snapshot_ids, :array_of_strings
  attribute :card_cycle_ids, :array_of_strings do
    @object.card_cycle_ids_in_database
  end
  attribute :card_cycle_names, :array_of_strings
  attribute :card_set_ids, :array_of_strings do
    @object.card_set_ids_in_database
  end
  attribute :card_set_names, :array_of_strings
  attribute :designed_by, :string
  attribute :narrative_text, :string
  attribute :printings_released_by, :array_of_strings
  attribute :pronouns, :string
  attribute :pronunciation_approximation, :string
  attribute :pronunciation_ipa, :string
  attribute :layout_id, :string

  # Extra face fields
  attribute :num_extra_faces, :integer

  attribute :faces, :array do
    faces = []

    unless @object.num_extra_faces.zero?
      @object.face_indices.each do |index|
        f = { index:, images: images(@object.latest_printing_id, @object.designed_by, face_index: index) }
        f[:base_link] = @object.faces_base_link[index] if @object.faces_base_link[index]
        f[:display_subtypes] = @object.faces_display_subtypes[index] if @object.faces_display_subtypes[index]
        f[:card_subtype_ids] = @object.faces_card_subtype_ids[index].compact if @object.faces_card_subtype_ids[index]
        f[:stripped_text] = @object.faces_stripped_text[index] if @object.faces_stripped_text[index]
        f[:stripped_title] = @object.faces_stripped_title[index] if @object.faces_stripped_title[index]
        f[:text] = @object.faces_text[index] if @object.faces_text[index]
        f[:title] = @object.faces_title[index] if @object.faces_title[index]
        faces << f
      end
    end
    faces
  end

  # Synthesized attributes
  attribute :card_abilities, :hash
  attribute :restrictions, :hash
  attribute :latest_printing_id, :string
  attribute :latest_printing_images, :hash do
    images(@object.latest_printing_id, @object.designed_by, has_narrative_image: @object.narrative_text.present?)
  end

  filter :card_cycle_id, :string do
    eq do |scope, value|
      scope.by_card_cycle(value)
    end
  end

  filter :card_set_id, :string do
    eq do |scope, value|
      scope.by_card_set(value)
    end
  end

  filter :search, :string, single: true do
    eq do |scope, value|
      query_builder = CardSearchQueryBuilder.new(value)
      if query_builder.parse_error.nil?
        scope.left_joins(query_builder.left_joins)
             .where(query_builder.where, *query_builder.where_values)
             .distinct
      else
        raise JSONAPI::Exceptions::BadRequest,
              format('Invalid search query: [%<query>s] / %<error>s', query: value[0],
                                                                      error: query_builder.parse_error)
      end
    end
  end

  many_to_many :card_cycles do
    link do |c|
      format('%<url>s?filter[id]=%<ids>s', url: Rails.application.routes.url_helpers.card_cycles_url,
                                           ids: c.card_cycle_ids_in_database.join(','))
    end
  end
  many_to_many :card_sets do
    link do |c|
      format('%<url>s?filter[id]=%<ids>s', url: Rails.application.routes.url_helpers.card_sets_url,
                                           ids: c.card_set_ids_in_database.join(','))
    end
  end
  many_to_many :card_subtypes do
    link do |c|
      card_subtype_ids = c.card_subtype_ids_in_database.empty? ? 'none' : c.card_subtype_ids_in_database.join(',')
      format('%<url>s?filter[id]=%<ids>s', url: Rails.application.routes.url_helpers.card_subtypes_url,
                                           ids: card_subtype_ids)
    end
  end
  belongs_to :card_type
  belongs_to :faction
  has_many :printings do
    link do |c|
      format('%<url>s?filter[card_id]=%<id>s', url: Rails.application.routes.url_helpers.printings_url, id: c.id)
    end
  end
  has_many :rulings
  has_many :reviews
  belongs_to :side

  many_to_many :decklists do
    link do |c|
      format('%<url>s?filter[card_id]=%<id>s', url: Rails.application.routes.url_helpers.decklists_url, id: c.id)
    end
  end

  many_to_many :card_pools

  private

  def images(id, designed_by, has_narrative_image: false, face_index: nil)
    url_prefix = Rails.configuration.x.printing_images.nrdb_classic_prefix
    face_suffix = "-#{face_index}" unless face_index.nil?
    image_sizes = {
      'tiny' => "#{url_prefix}/tiny/#{id}#{face_suffix}.jpg",
      'small' => "#{url_prefix}/small/#{id}#{face_suffix}.jpg",
      'medium' => "#{url_prefix}/medium/#{id}#{face_suffix}.jpg",
      'large' => "#{url_prefix}/large/#{id}#{face_suffix}.jpg"
    }
    image_sizes[:xlarge] = "#{url_prefix}/xlarge/#{id}#{face_suffix}.webp" if designed_by == 'null_signal_games'

    image_sizes['narrative'] = "#{url_prefix}/xlarge/#{id}#{face_suffix}-narrative.webp" if has_narrative_image

    {
      'nrdb_classic' => image_sizes
    }
  end
end
