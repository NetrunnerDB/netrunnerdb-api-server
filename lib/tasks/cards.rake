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
    Side.import sides, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all }
  end

  def import_factions(path)
    factions = JSON.parse(File.read(path))
    factions.map! do |f|
      {
        code: f['code'],
        name: f['name'],
        is_mini: f['is_mini']
      }
    end
    Faction.import factions, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all }
  end

  def import_types(path)
    types = JSON.parse(File.read(path))
    types = types.select {|t| t['is_subtype'] == false}
    types.map! do |t|
      {
        code: t['code'],
        name: t['name'],
      }
    end
    CardType.import types, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all }
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
        code: k,
        name: v
      }
    end 
    Subtype.import subtypes, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all }
  end

  def import_cards(cards)
    factions = Faction.all.index_by(&:code)
    sides = Side.all.index_by(&:code)
    types = CardType.all.index_by(&:code)
    subtypes = Subtype.all.index_by(&:code)

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
        advancement_requirement: card["advancement_cost"],
        agenda_points: card["agendaUpoints"],
        base_link: card["base_link"],
        code: stripped_title_to_card_code(card["stripped_title"]),
        cost: card["cost"],
        deck_limit: card["deck_limit"],
        influence_cost: card["faction_cost"],
        influence_limit: card["influence_limit"],
        memory_cost: card["memory_cost"],
        minimum_deck_size: card["minimum_deck_size"],
        name: card["title"],
        strength: card["strength"],
        subtypes: card["keywords"],
        text: card["text"],
        trash_cost: card["trash_cost"],
        uniqueness: card["uniqueness"]
      )
      new_card.faction = factions[card["faction_code"]] if card["faction_code"]
      new_card.side = sides[card["side_code"]] if card["side_code"]
      new_card.card_type = types[card["type_code"]] if card["type_code"]
      new_cards << new_card
    end

    puts 'About to save %d cards...' % new_cards.length
    num_cards = 0
    new_cards.each_slice(250) { |s|
      num_cards += s.length
      puts '  %d cards' % num_cards
      Card.import s, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all }
    }
  end

  # We don't reload JSON files in here because we have already saved all the cards
  # with their subtypes fields and can parse from there.
  def import_card_subtypes
    subtypes = Subtype.all.index_by(&:code)
    cards = Card.all
    card_code_to_subtype_code = []
    cards.each { |c|
      keywords_to_subtype_codes(c.subtypes).each { |k,v|
        card_code_to_subtype_code << [c.code, subtypes[k].code]
      }
    }
    puts "Have to insert %d card -> subtype mappings." % card_code_to_subtype_code.length
    # Use a transaction since we are deleting the mapping table.
    ActiveRecord::Base.transaction do
      puts 'Clear out existing card -> subtype mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM cards_subtypes")
        puts 'Hit an error while delete card -> subtype mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      num_assoc = 0
      card_code_to_subtype_code.each_slice(250) { |m|
        num_assoc += m.length
        puts '  %d card -> subtype associations' % num_assoc
        sql = "INSERT INTO cards_subtypes (card_code, subtype_code) VALUES " 
        vals = []
        m.each { |m|
         # TODO(plural): use the associations object for this or ensure this is safe
         puts m
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
        code: c['code'],
        name: c['name'],
      }
    end
    Cycle.import cycles, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all } 
  end

  def import_set_types
    # TODO(plural): Make json files for set types.
    subtypes = Subtype.all.index_by(&:code)
    set_types = [
      { code: 'campaign', name: 'Campaign' },
      { code: 'core', name: 'Core' },
      { code: 'data_pack', name: 'Data Pack' },
      { code: 'deluxe', name: 'Deluxe' },
      { code: 'draft', name: 'Draft' },
      { code: 'expansion', name: 'Expansion' },
      { code: 'promo', name: 'Promo' }
    ]
    CardSetType.import set_types, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all }
  end

  def import_sets(path)
    # TODO(plural): Get mappings into the JSON files.
    set_type_mapping = {
      "terminal-directive-campaign" => 'campaign',
      "revised-core-set" => 'core',
      "system-gateway" => 'core',
      "system-core-2019" => 'core',
      "core-set" => 'core',
      "system-update-2021" => 'core',
      "reign-and-reverie" => 'deluxe', 
      "data-and-destiny" => 'deluxe',
      "order-and-chaos" => 'deluxe',
      "creation-and-control" => 'deluxe',
      "honor-and-profit" => 'deluxe',
      "draft" => 'draft',
      "magnum-opus" => 'expansion', 
      "magnum-opus-reprint" => 'expansion',
      "uprising-booster-pack" => 'expansion',
      "napd-multiplayer" => 'promo',
    }
    cycles = Cycle.all.index_by(&:code)
    sets = JSON.parse(File.read(path))
    # TODO(plural): Get the updated code values in the JSON files, probably with a new name.
    sets.map! do |s|
      {
          "code": set_name_to_code(s["name"]),
          "name": s["name"],
          # TODO(plural): Make this a proper date type, not a string.
          "date_release": s["date_release"],
          "size": s["size"], 
          "cycle_code": cycles[s["cycle_code"]].code,
          "card_set_type_code": set_type_mapping.fetch(set_name_to_code(s["name"]), "data_pack")
      }
    end
    CardSet.import sets, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all } 
  end

  def import_printings(pack_cards_json, packs_path)
    raw_packs = JSON.parse(File.read(packs_path))
    old_pack_code_to_set_code = {} 
    raw_packs.each{ |r|
      old_pack_code_to_set_code[r["code"]] = set_name_to_code(r["name"])
    }
    raw_cards = Card.all.index_by(&:code)
    sets = CardSet.all.index_by(&:code)

    new_printings = []
    pack_cards_json.each { |set_card|
      card = raw_cards[stripped_title_to_card_code(set_card["stripped_title"])]
      set = sets[old_pack_code_to_set_code[set_card["pack_code"]]]

      new_printings << Printing.new(
        printed_text: card.text,
        printed_uniqueness: card.uniqueness,
        code: set_card["code"],
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
      Printing.import s, on_duplicate_key_update: { conflict_target: [ :code ], columns: :all }
    }
  end

  task :import, [:json_dir] => [:environment] do |t, args|
#    args.with_defaults(:json_dir => '/netrunner-cards-json/')
#    puts 'Import card data...'
#
#    puts 'Importing Sides...'
#    import_sides(args[:json_dir] + '/sides.json')
#
#    puts 'Import factions...'
#    import_factions(args[:json_dir] + '/factions.json')
#
#    puts 'Importing Types...'
#    import_types(args[:json_dir] + '/types.json')
#
#    # The JSON from the files in packs/ are used by multiple methods.
#    pack_cards_json = load_pack_card_files(args[:json_dir] + '/pack/*.json')
#
#    puts 'Importing Subtypes...,'
#    import_subtypes(pack_cards_json)
#
#    puts 'Importing Cards...'
#    import_cards(pack_cards_json)
#
#    puts 'Importing Cycles...'
#    import_cycles(args[:json_dir] + '/cycles.json')
#
#    puts 'Importing Card Set Types...'
#    import_set_types()
#
#    puts 'Importing Sets...'
#    import_sets(args[:json_dir] + '/packs.json')

    puts 'Importing Subtypes for Cards...'
    import_card_subtypes()

#    puts('Importing Printings...')
#    import_printings(pack_cards_json, args[:json_dir] + '/packs.json')

    puts 'Done!'
  end
end
