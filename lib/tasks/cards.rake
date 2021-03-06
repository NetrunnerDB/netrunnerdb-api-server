namespace :cards do
  desc 'import card data - json_dir defaults to /netrunner-cards-json/ if not specified.'

  def text_to_id(t)
    t.downcase
      .unicode_normalize(:nfd)
      .gsub(/\P{ASCII}/, '')
      .gsub(/'s(\p{Space}|\z)/, 's\1')
      .split(/[\p{Space}\p{Punct}]+/)
      .reject { |s| s&.strip&.empty? }
      .join("_")
  end

  def load_multiple_json_files(path)
    cards = []
    Dir.glob(path) do |f|
      next if File.directory? f

      File.open(f) do |file|
        (cards << JSON.parse(File.read(file))).flatten!
      end
    end
    cards
  end

  def import_sides(sides_path)
    sides = JSON.parse(File.read(sides_path))
    sides.map! do |s|
      {
        id: s['id'],
        name: s['name'],
      }
    end
    Side.import sides, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_factions(path)
    factions = JSON.parse(File.read(path))
    factions.map! do |f|
      {
        id: f['id'],
        description: f['description'],
        is_mini: f['is_mini'],
        name: f['name'],
        side_id: f['side_id'],
      }
    end
    Faction.import factions, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_types(path)
    types = JSON.parse(File.read(path))
    types.map! do |t|
      {
        id: t['id'],
        name: t['name'],
        side_id: t['side_id'],
      }
    end
    CardType.import types, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_subtypes(path)
    subtypes = JSON.parse(File.read(path))
    subtypes.map! do |st|
      {
        id: st['id'],
        name: st['name'],
      }
    end
    CardSubtype.import subtypes, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def flatten_subtypes(all_subtypes, card_subtypes)
    return if card_subtypes.nil?
    subtype_names = []
    card_subtypes.each do |subtype|
      subtype_names << all_subtypes[subtype].name
    end
    return subtype_names.join(" - ")
  end

  def import_cards(cards)
    subtypes = CardSubtype.all.index_by(&:id)

    new_cards = []
    cards.each do |card|
      new_card = Card.new(
        id: card["id"],
        card_type_id: card["card_type_id"],
        side_id: card["side_id"],
        faction_id: card["faction_id"],
        advancement_requirement: card["advancement_requirement"],
        agenda_points: card["agenda_points"],
        base_link: card["base_link"],
        cost: card["cost"],
        deck_limit: card["deck_limit"],
        influence_cost: card["influence_cost"],
        influence_limit: card["influence_limit"],
        memory_cost: card["memory_cost"],
        minimum_deck_size: card["minimum_deck_size"],
        title: card["title"],
        stripped_title: card["stripped_title"],
        strength: card["strength"],
        stripped_text: card["stripped_text"],
        text: card["text"],
        trash_cost: card["trash_cost"],
        is_unique: card["is_unique"],
        display_subtypes: flatten_subtypes(subtypes, card["subtypes"]),
      )
      new_cards << new_card
    end

    puts '  About to save %d cards...' % new_cards.length
    num_cards = 0
    new_cards.each_slice(250) { |s|
      num_cards += s.length
      puts '  %d cards' % num_cards
      Card.import s, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
    }
  end

  # We don't reload JSON files in here because we have already saved all the cards
  # with their subtypes fields and can parse from there.
  def import_card_subtypes(cards)
    card_id_to_subtype_id = []
    cards.each { |c|
      next if c["subtypes"].nil?
      c["subtypes"].each do |st|
        card_id_to_subtype_id << [c["id"], st]
      end
    }
    # Use a transaction since we are deleting the mapping table.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing card -> subtype mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM cards_card_subtypes")
        puts 'Hit an error while deleting card -> subtype mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      num_assoc = 0
      card_id_to_subtype_id.each_slice(250) { |m|
        num_assoc += m.length
        puts '  %d card -> subtype associations' % num_assoc
        sql = "INSERT INTO cards_card_subtypes (card_id, card_subtype_id) VALUES "
        vals = []
        m.each { |m|
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
        id: c['id'],
        name: c['name'],
      }
    end
    CardCycle.import cycles, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_set_types(path)
    set_types = JSON.parse(File.read(path))
    set_types.map! do |t|
      {
        id: t['id'],
        name: t['name'],
      }
    end
    CardSetType.import set_types, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def update_date_release_for_cycles
    CardCycle.all().each {|c|
      c.date_release = (c.card_sets.min_by {:date_release}).date_release
      c.save
    }
  end

  def import_sets(path)
    cycles = CardCycle.all
    set_types = CardSetType.all
    printings = JSON.parse(File.read(path))
    printings.map! do |s|
      {
          "id": s["id"],
          "name": s["name"],
          "date_release": s["date_release"],
          "size": s["size"],
          "card_cycle_id": s["card_cycle_id"],
          "card_set_type_id": s["card_set_type_id"],
          "position": s["position"],
      }
    end
    CardSet.import printings, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_printings(printings)
    card_sets = CardSet.all.index_by(&:id)

    new_printings = []
    printings.each { |printing|
      new_printings << Printing.new(
        printed_text: printing["printed_text"],
        stripped_printed_text: printing["stripped_printed_text"],
        printed_is_unique: printing["printed_is_unique"],
        id: printing["id"],
        flavor: printing["flavor"],
        display_illustrators: printing["illustrator"],
        position: printing["position"],
        quantity: printing["quantity"],
        card_id: printing["card_id"],
        card_set_id: printing["card_set_id"],
        date_release: card_sets[printing["card_set_id"]].date_release,
      )
    }

    num_printings = 0
    new_printings.each_slice(250) { |s|
      num_printings += s.length
      puts '  %d printings' % num_printings
      Printing.import s, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
    }
  end

  def import_illustrators()
    # Use a transaction since we are deleting the illustrator and mapping tables.
    ActiveRecord::Base.transaction do
      puts 'Clear out existing illustrator -> printing mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM illustrators_printings")
        puts 'Hit an error while deleting illustrator -> printing mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      puts 'Clear out existing illustrators'
      unless ActiveRecord::Base.connection.delete("DELETE FROM illustrators")
        puts 'Hit an error while deleting illustrators. rolling back.'
        raise ActiveRecord::Rollback
      end

      illustrators = Set[]
      illustrators_to_printings = []
      num_its = 0
      printings = Printing.all
      printings.each { |printing|
        if printing.display_illustrators then
          printing.display_illustrators.split(', ').each { |i|
            illustrators.add(i)
            num_its += 1
            illustrators_to_printings << {
              "illustrator_id": text_to_id(i),
              "printing_id": printing.id
            }
          }
        end
      }

      ill = []
      illustrators.each { |i|
        ill << {
          "id": text_to_id(i),
          "name": i
        }
      }

      Illustrator.import ill, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
      IllustratorPrinting.import illustrators_to_printings, on_duplicate_key_update: { conflict_target: [ :illustrator_id, :printing_id ], columns: :all }
    end
  end

  def import_formats(formats_json)
    formats = []
    formats_json.each { |f|
      active_id = nil
      f['snapshots'].each do |s|
        next if !s['active']
        active_id = s['id']
      end
      formats << Format.new(
        id: f['id'],
        name: f['name'],
        active_snapshot_id: active_id
      )
    }
    Format.import formats, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_card_pools(card_pools)
    new_card_pools = []
    card_pools.each { |p|
      new_card_pools << CardPool.new(
        id: p['id'],
        name: p['name'],
        format_id: p['format_id']
      )
    }
    CardPool.import new_card_pools, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_card_pool_card_cycles(card_pools)
    card_pool_id_to_cycle_id = []

    # Collect each card pool's cycles
    card_pools.each do |p|
      next if p['card_cycle_ids'].nil?
      p['card_cycle_ids'].each do |s|
        card_pool_id_to_cycle_id << [p['id'], s]
      end
    end

    # Use a transaction since we are deleting the mapping table.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing card_pool -> cycle mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM card_pools_card_cycles")
        puts 'Hit an error while deleting card_pool -> cycle mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end

      num_assoc = 0
      card_pool_id_to_cycle_id.each_slice(250) { |m|
        num_assoc += m.length
        puts '  %d card_pool -> cycle associations' % num_assoc
        sql = "INSERT INTO card_pools_card_cycles (card_pool_id, card_cycle_id) VALUES "
        vals = []
        m.each { |m|
          # TODO(ams): use the associations object for this or ensure this is safe
          vals << "('%s', '%s')" % [m[0], m[1]]
        }
        sql << vals.join(", ")
        unless ActiveRecord::Base.connection.execute(sql)
          puts 'Hit an error while inserting card_pool -> cycle mappings. Rolling back.'
          raise ActiveRecord::Rollback
        end
      }
    end
  end

  def import_card_pool_card_sets(card_pools)
    card_pool_id_to_set_id = []

    # Get implied sets from cycles in the card_pool
    ActiveRecord::Base.connection.execute('SELECT card_pool_id, id FROM card_pools_card_cycles r INNER JOIN card_sets AS s ON r.card_cycle_id = s.card_cycle_id').each do |s|
      card_pool_id_to_set_id << [s['card_pool_id'], s['id']]
    end

    # Collect each card pool's sets
    card_pools.each do |p|
      next if p['card_set_ids'].nil?
      p['card_set_ids'].each do |s|
        card_pool_id_to_set_id << [p['id'], s]
      end
    end

    # Use a transaction since we are deleting the mapping table.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing card_pool -> card cycle mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM card_pools_card_sets")
        puts 'Hit an error while deleting card_pool -> card set mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end

      num_assoc = 0
      card_pool_id_to_set_id.each_slice(250) { |m|
        num_assoc += m.length
        puts '  %d card_pool -> card set associations' % num_assoc
        sql = "INSERT INTO card_pools_card_sets (card_pool_id, card_set_id) VALUES "
        vals = []
        m.each { |m|
          # TODO(ams): use the associations object for this or ensure this is safe
          vals << "('%s', '%s')" % [m[0], m[1]]
        }
        sql << vals.join(", ")
        unless ActiveRecord::Base.connection.execute(sql)
          puts 'Hit an error while inserting card_pool -> card set mappings. Rolling back.'
          raise ActiveRecord::Rollback
        end
      }
    end
  end

  def import_card_pool_cards(card_pools)
    card_pool_id_to_card_id = []

    # Get implied cards from sets in the card_pool
    ActiveRecord::Base.connection.execute('SELECT card_pool_id, card_id FROM card_pools_card_sets AS r INNER JOIN printings AS p ON r.card_set_id = p.card_set_id GROUP BY 1,2').each do |s|
      card_pool_id_to_card_id << [s['card_pool_id'], s['card_id']]
    end

    # Collect each card pool's cards
    card_pools.each do |p|
      next if p['cards'].nil?
      p['cards'].each do |s|
        card_pool_id_to_card_id << [p['id'], s]
      end
    end

    # Use a transaction since we are deleting the mapping table.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing card_pool -> card mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM card_pools_cards")
        puts 'Hit an error while deleting card_pool -> card mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end

      num_assoc = 0
      card_pool_id_to_card_id.each_slice(1000) { |m|
        num_assoc += m.length
        puts '  %d card_pool -> card associations' % num_assoc
        sql = "INSERT INTO card_pools_cards (card_pool_id, card_id) VALUES "
        vals = []
        m.each { |m|
          # TODO(ams): use the associations object for this or ensure this is safe
          vals << "('%s', '%s')" % [m[0], m[1]]
        }
        sql << vals.join(", ")
        unless ActiveRecord::Base.connection.execute(sql)
          puts 'Hit an error while inserting card_pool -> card mappings. Rolling back.'
          raise ActiveRecord::Rollback
        end
      }
    end
  end

  def import_restrictions(restrictions)
    new_restrictions = []
    restrictions.each { |m|
      new_restrictions << Restriction.new(
        id: m['id'],
        name: m['name'],
        date_start: m['date_start'],
        point_limit: m['point_limit']
      )
    }
    Restriction.import new_restrictions, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_restriction_cards(restrictions)
    banned = []
    restricted = []
    universal_faction_cost = []
    global_penalty = []
    points = []
    restrictions.each { |r|
      # Banned cards
      if !r['banned'].nil?
        r['banned'].each do |card|
          banned << RestrictionCardBanned.new(
            restriction_id: r['id'],
            card_id: card
          )
        end
      end
      # Restricted cards
      if !r['restricted'].nil?
        r['restricted'].each do |card|
          restricted << RestrictionCardRestricted.new(
            restriction_id: r['id'],
            card_id: card
          )
        end
      end
      # Cards with a universal faction cost
      if !r['universal_faction_cost'].nil?
        r['universal_faction_cost'].each do |cost, cards|
          cards.each do |card|
            universal_faction_cost << RestrictionCardUniversalFactionCost.new(
              restriction_id: r['id'],
              card_id: card,
              value: cost
            )
          end
        end
      end
      # Cards with a global influence penalty
      if !r['global_penalty'].nil?
        r['global_penalty'].each do |cost, cards|
          cards.each do |card|
            global_penalty << RestrictionCardGlobalPenalty.new(
              restriction_id: r['id'],
              card_id: card,
              value: cost
            )
          end
        end
      end
      # Cards with a points cost
      if !r['points'].nil?
        r['points'].each do |cost, cards|
          cards.each do |card|
            points << RestrictionCardPoints.new(
              restriction_id: r['id'],
              card_id: card,
              value: cost
            )
          end
        end
      end
    }

    # Use a transaction since we are deleting all the restriction mapping tables.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing restriction -> card mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM restrictions_cards_banned")
        puts 'Hit an error while deleting banned cards mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end
      unless ActiveRecord::Base.connection.delete("DELETE FROM restrictions_cards_restricted")
        puts 'Hit an error while deleting restricted cards mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end
      unless ActiveRecord::Base.connection.delete("DELETE FROM restrictions_cards_universal_faction_cost")
        puts 'Hit an error while deleting universal faction cost cards mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end
      unless ActiveRecord::Base.connection.delete("DELETE FROM restrictions_cards_global_penalty")
        puts 'Hit an error while deleting global penalty cards mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end
      unless ActiveRecord::Base.connection.delete("DELETE FROM restrictions_cards_points")
        puts 'Hit an error while deleting points cards mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end
      RestrictionCardBanned.import banned
      RestrictionCardRestricted.import restricted
      RestrictionCardUniversalFactionCost.import universal_faction_cost
      RestrictionCardGlobalPenalty.import global_penalty
      RestrictionCardPoints.import points
    end
  end

  def import_restriction_subtypes(restrictions)
    banned = []
    restrictions.each { |r|
      subtypes = r['subtypes']
      next if subtypes.nil?
      # Banned subtypes
      if !subtypes['banned'].nil?
        subtypes['banned'].each do |subtype|
          banned << RestrictionCardSubtypeBanned.new(
            restriction_id: r['id'],
            card_subtype_id: subtype
          )
        end
      end
    }

    # Use a transaction since we are deleting the restriction mapping table.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing restriction -> subtype mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM restrictions_card_subtypes_banned")
        puts 'Hit an error while deleting banned subtypes mappings. Rolling back.'
        raise ActiveRecord::Rollback
      end
      RestrictionCardSubtypeBanned.import banned
    end
  end

  def import_snapshots(formats)
    snapshots = []
    formats.each { |f|
      f['snapshots'].each do |s|
        snapshots << Snapshot.new(
          id: s['id'],
          format_id: f['id'],
          card_pool_id: s['card_pool_id'],
          date_start: s['date_start'],
          restriction_id: s['restriction_id'],
          active: !!s['active']
        )
      end
    }
    Snapshot.import snapshots, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  task :import, [:json_dir] => [:environment] do |t, args|
    args.with_defaults(:json_dir => '/netrunner-cards-json/v2/')
    puts 'Import card data...'

    # Preload directories that are used multiple times
    cards_json = load_multiple_json_files(args[:json_dir] + '/cards/*.json')
    printings_json = load_multiple_json_files(args[:json_dir] + '/printings/*.json')
    pack_cards_json = load_multiple_json_files(args[:json_dir] + '/pack/*.json')
    card_pools_json = load_multiple_json_files(args[:json_dir] + '/card_pools/*.json')
    formats_json = load_multiple_json_files(args[:json_dir] + '/formats/*.json')
    restrictions_json = load_multiple_json_files(args[:json_dir] + '/restrictions/*/*.json')

    puts 'Importing Sides...'
    import_sides(args[:json_dir] + '/sides.json')

    puts 'Import Factions...'
    import_factions(args[:json_dir] + '/factions.json')

    puts 'Importing Cycles...'
    import_cycles(args[:json_dir] + '/card_cycles.json')

    puts 'Importing Card Set Types...'
    import_set_types(args[:json_dir] + '/card_set_types.json')

    puts 'Importing Sets...'
    import_sets(args[:json_dir] + '/card_sets.json')

    puts 'Updating date_release for Cycles'
    update_date_release_for_cycles()

    puts 'Importing Types...'
    import_types(args[:json_dir] + '/card_types.json')

    puts 'Importing Subtypes...'
    import_subtypes(args[:json_dir] + '/card_subtypes.json')

    puts 'Importing Cards...'
    import_cards(cards_json)

    puts 'Importing Subtypes for Cards...'
    import_card_subtypes(cards_json)

    puts 'Importing Printings...'
    import_printings(printings_json)

    puts 'Importing Illustrators...'
    import_illustrators()

    puts 'Importing Formats...'
    import_formats(formats_json)

    puts 'Importing Card Pools...'
    import_card_pools(card_pools_json)

    puts 'Importing Card-Pool-to-Cycle relations...'
    import_card_pool_card_cycles(card_pools_json)

    puts 'Importing Card-Pool-to-Set relations...'
    import_card_pool_card_sets(card_pools_json)

    puts 'Importing Card-Pool-to-Card relations...'
    import_card_pool_cards(card_pools_json)

    puts 'Importing Restrictions...'
    import_restrictions(restrictions_json)

    puts 'Importing Restriction Cards...'
    import_restriction_cards(restrictions_json)

    puts 'Importing Restriction Subtypes...'
    import_restriction_subtypes(restrictions_json)

    puts 'Importing Format Snapshots...'
    import_snapshots(formats_json)

    puts 'Refreshing materialized view for restrictions...'
    Scenic.database.refresh_materialized_view(:unified_restrictions, concurrently: false, cascade: false)

    puts 'Done!'
  end
end
