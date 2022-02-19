namespace :cards do
  desc 'import card data - json_dir defaults to /netrunner-cards-json/ if not specified.'

  def load_pack_card_files(path)
    cards = []
    Dir.glob(path) do |f|
      next if File.directory? f

      File.open(f) do |file|
        (cards << JSON.parse(File.read(file))).flatten!
      end
    end
    cards
  end

  # Valid subtype code characters are limited to [a-z0-9_]
  def subtype_name_to_code(subtype)
    subtype.gsub(/-/, ' ').gsub(/ /, '_').downcase
  end

  # Make a map from subtype code -> name
  def keywords_to_subtype_codes(keywords)
    subtypes = {}
    return subtypes if keywords == nil
    keywords = keywords.split(' - ')
    keywords.each { |k|
      subtypes[subtype_name_to_code(k)] = k
    }
    return subtypes
  end

  # Normalize set names by stripping apostrophes and replacing spaces with -.
  def set_name_to_code(name)
    name.gsub(/'/, '').gsub(/ /, '-').downcase
  end

  def stripped_title_to_card_code(stripped_title)
    stripped_title
      .downcase
      # Characters ! : " , ( ) * are stripped.
      .gsub(/[!:",\(\)\*]/, '')
      # Single quotes before or after a space and before a - are removed.
      # This normalized a word like Earth's to earths which reads better
      # than earth-s
      .gsub(/' /, ' ')
      .gsub(/ '/, ' ')
      .gsub(/'-/, '-')
      # Periods followed by a space (Such as in Dr. Lovegood) are removed.
      .gsub('. ', ' ')
      # Trailing periods are removed.
      .gsub(/\.$/, '')
      .gsub(/[\. '\/\.&;]/, '-')
  end

  def import_sides(sides_path)
    sides = JSON.parse(File.read(sides_path))
    sides.map! do |s|
      {
        id: s['code'],
        name: s['name'],
      }
    end
    Side.import sides, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_factions(path)
    factions = JSON.parse(File.read(path))
    factions.map! do |f|
      {
        id: f['code'],
        side_id: f['side_code'],
        name: f['name'],
        is_mini: f['is_mini']
      }
    end
    Faction.import factions, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_types(path)
    types = JSON.parse(File.read(path))
    types = types.select {|t| t['is_subtype'] == false}
    types.map! do |t|
      {
        id: t['code'],
        name: t['name'],
      }
    end
    CardType.import types, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_subtypes(packs_json)
    subtypes = {}
    packs_json.each { |c|
      next if c['keywords'] == nil
      keywords = c['keywords'].split(' - ')
      keywords.each { |k|
        subtypes[subtype_name_to_code(k)] = k
      }
    }
    subtypes = subtypes.to_a.map do |k, v|
      {
        id: k,
        name: v
      }
    end
    Subtype.import subtypes, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_cards(cards)
    new_cards = []
    seen_cards = {}
    cards.each do |card|
      # The pack files contain all the printings, but tests in the JSON repo ensure
      # that all the text is identical, so we can use the first one we see by title.
      if seen_cards.key?(card["title"])
        next
      end
      seen_cards[card["title"]] = true

      new_card = Card.new(
        id: stripped_title_to_card_code(card["stripped_title"]),
        card_type_id: card["type_code"],
        side_id: card["side_code"],
        faction_id: card["faction_code"],
        advancement_requirement: card["advancement_cost"],
        agenda_points: card["agenda_points"],
        base_link: card["base_link"],
        cost: card["cost"],
        deck_limit: card["deck_limit"],
        influence_cost: card["faction_cost"],
        influence_limit: card["influence_limit"],
        memory_cost: card["memory_cost"],
        minimum_deck_size: card["minimum_deck_size"],
        name: card["title"],
        strength: card["strength"],
        text: card["text"],
        trash_cost: card["trash_cost"],
        uniqueness: card["uniqueness"],
        keywords: card["keywords"],
      )
      new_cards << new_card
    end

    puts 'About to save %d cards...' % new_cards.length
    num_cards = 0
    new_cards.each_slice(250) { |s|
      num_cards += s.length
      puts '  %d cards' % num_cards
      Card.import s, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
    }
  end

  # We don't reload JSON files in here because we have already saved all the cards
  # with their subtypes fields and can parse from there.
  def import_card_subtypes
    # TODO(plural): Deal with caïssa type.
    subtypes = Subtype.all.index_by(&:id)
    cards = Card.all
    card_id_to_subtype_id = []
    cards.each { |c|
      keywords_to_subtype_codes(c.keywords).each { |k,v|
        card_id_to_subtype_id << [c.id, subtypes[k].id]
      }
    }
    # Use a transaction since we are deleting the mapping table.
    ActiveRecord::Base.transaction do
      puts 'Clear out existing card -> subtype mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM cards_subtypes")
        puts 'Hit an error while delete card -> subtype mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      num_assoc = 0
      card_id_to_subtype_id.each_slice(250) { |m|
        num_assoc += m.length
        puts '  %d card -> subtype associations' % num_assoc
        sql = "INSERT INTO cards_subtypes (card_id, subtype_id) VALUES "
        vals = []
        m.each { |m|
         # TODO(plural): use the associations object for this or ensure this is safe
         vals << "('%s', '%s')" % [m[0], m[1]]
        }
        sql << vals.join(", ")
        unless ActiveRecord::Base.connection.execute(sql)
          puts 'Hit an error while inserting card -> subtype mappings. rolling back.'
          raise ActiveRecord::Rollback
        end
      }
    end
  end

  def import_cycles(path)
    cycles = JSON.parse(File.read(path))
    cycles.map! do |c|
      {
        id: c['code'],
        name: c['name'],
      }
    end
    CardCycle.import cycles, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_set_types(path)
    set_types = JSON.parse(File.read(path))
    set_types.map! do |t|
      {
        id: t['code'],
        name: t['name'],
      }
    end
    CardSetType.import set_types, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_sets(path)
    cycles = CardCycle.all
    set_types = CardSetType.all
    sets = JSON.parse(File.read(path))
    # TODO(plural): Get the updated code values in the JSON files, probably with a new name.
    sets.map! do |s|
      {
          "id": set_name_to_code(s["name"]),
          "name": s["name"],
          # TODO(plural): Make this a proper date type, not a string.
          "date_release": s["date_release"],
          "size": s["size"],
          "card_cycle_id": s["cycle_code"],
          "card_set_type_id": s["type"]
      }
    end
    CardSet.import sets, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_printings(pack_cards_json, packs_path)
    raw_packs = JSON.parse(File.read(packs_path))
    old_pack_id_to_set_id = {}
    raw_packs.each{ |r|
      old_pack_id_to_set_id[r["code"]] = set_name_to_code(r["name"])
    }
    raw_cards = Card.all.index_by(&:id)
    sets = CardSet.all.index_by(&:id)

    new_printings = []
    pack_cards_json.each { |set_card|
      card = raw_cards[stripped_title_to_card_code(set_card["stripped_title"])]
      set = sets[old_pack_id_to_set_id[set_card["pack_code"]]]

      new_printings << Printing.new(
        printed_text: card.text,
        printed_uniqueness: card.uniqueness,
        id: set_card["code"],
        flavor: set_card["flavor"],
        illustrator: set_card["illustrator"],
        position: set_card["position"],
        quantity: set_card["quantity"],
        date_release: set["date_release"],
        card: card,
        card_set: set
      )
    }

    num_printings = 0
    new_printings.each_slice(250) { |s|
      num_printings += s.length
      puts '  %d printings' % num_printings
      Printing.import s, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
    }
  end

  task :import, [:json_dir] => [:environment] do |t, args|
    args.with_defaults(:json_dir => '/netrunner-cards-json/')
    puts 'Import card data...'

    # The JSON from the files in packs/ are used by multiple methods.
    pack_cards_json = load_pack_card_files(args[:json_dir] + '/pack/*.json')

    puts 'Importing Sides...'
    import_sides(args[:json_dir] + '/sides.json')

    puts 'Import factions...'
    import_factions(args[:json_dir] + '/factions.json')

    puts 'Importing Cycles...'
    import_cycles(args[:json_dir] + '/cycles.json')

    puts 'Importing Types...'
    import_types(args[:json_dir] + '/types.json')

    puts 'Importing Subtypes...,'
    import_subtypes(pack_cards_json)

    puts 'Importing Cards...'
    import_cards(pack_cards_json)

    puts 'Importing Subtypes for Cards...'
    import_card_subtypes()

    puts 'Importing Card Set Types...'
    import_set_types(args[:json_dir] + '/set_types.json')

    puts 'Importing Sets...'
    import_sets(args[:json_dir] + '/packs.json')

    puts 'Importing Printings...'
    import_printings(pack_cards_json, args[:json_dir] + '/packs.json')

    puts 'Done!'
  end
end
