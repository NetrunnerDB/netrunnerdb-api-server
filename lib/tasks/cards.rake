require 'optparse'

namespace :cards do
  desc 'import card data - json_dir defaults to /netrunner-cards-json/v2/ if not specified.'

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
        agenda_points: card["agenda_points"],
        base_link: card["base_link"],
        deck_limit: card["deck_limit"],
        influence_cost: card["influence_cost"],
        influence_limit: card["influence_limit"],
        memory_cost: card["memory_cost"],
        minimum_deck_size: card["minimum_deck_size"],
        title: card["title"],
        stripped_title: card["stripped_title"],
        stripped_text: card["stripped_text"],
        text: card["text"],
        trash_cost: card["trash_cost"],
        is_unique: card["is_unique"],
        display_subtypes: flatten_subtypes(subtypes, card["subtypes"]),
        attribution: card["attribution"],
        layout_id: card.key?("layout_id") ? card["layout_id"] : 'normal',
      )
      if card.key?("cost")
        new_card.cost = (card["cost"].nil? ? -1 : card["cost"])
      end
      if card.key?("strength")
        new_card.strength = (card["strength"].nil? ? -1 : card["strength"])
      end

      if new_card.card_type_id == 'agenda'
        new_card.advancement_requirement = (card["advancement_requirement"].nil? ? -1 : card["advancement_requirement"])
      end

      # Look for specific abilities and attributes:
      if new_card.text
        m = new_card.text.match(/\+([X\d]+)\[link\]/)
        if m && m.captures.length == 1
          link_provided = m.captures[0]
          # Null is equivalent to "does not provide link" and we will use -1 to map to X.
          # TODO(plural): Ensure that any cards that match this condition end up with -1
          new_card.link_provided = link_provided == 'X' ? -1 : link_provided
        end
      end

      if new_card.text
        m = new_card.text.match(/\+([X\d]+)\[mu\]/)
        if m && m.captures.length == 1
          mu_provided = m.captures[0]
          # Null is equivalent to "does not provide mu" and we will use -1 to map to X.
          new_card.mu_provided = (mu_provided == 'X' ? -1 : mu_provided)
        end
      end

      if new_card.text
        m = new_card.text.match('([X\d]+)\[recurring-credit\]')
        if m && m.captures.length == 1
          num_recurring_credits = m.captures[0]
          # Null is equivalent to "does not provide recurring credits" and we will use -1 to map to X.
          new_card.recurring_credits_provided = num_recurring_credits == 'X' ? -1 : num_recurring_credits
        end
      end

      if new_card.text && new_card.text.include?('[interrupt] →')
        new_card.interrupt = true
      end

      # Geist and Tech trader are more trash *triggers* than abilities.
      if new_card.text && new_card.text.include?('[trash]')
        new_card.trash_ability = true
      end

      if new_card.text && new_card.card_type_id == 'ice' && new_card.text.include?('[subroutine]')
        # First look for gains subroutines text, record it and then remove it.
        # This only works with single gains "[subroutine]" instances, which is fine for now.
        t = new_card.text
        m = t.match(/gains "\[subroutine\].*?"/)
        gains_subroutines = false
        if m
          gains_subroutines = true
          t = t.gsub(/gains "\[subroutine\].*?"/, '')
        end
        num_printed_subroutines = t.scan(/\[subroutine\]/).length
        new_card.gains_subroutines = gains_subroutines
        new_card.num_printed_subroutines = num_printed_subroutines
      end

      if new_card.text && new_card.text.include?(' can be advanced')
        if new_card.text.match('%s can be advanced' % new_card.title)
          new_card.advanceable = true
        end
      end

      # leaving this vague to catch things that have and impose additional costs.
      if new_card.text && new_card.text.include?('As an additional cost to')
        new_card.additional_cost = true
      end

      if new_card.text && (new_card.text.include?('When the Runner encounters this ice') || new_card.text.include?('When the Runner encounters %s' % new_card.title))
        new_card.on_encounter_effect = true
      end

      if new_card.text && (new_card.text.include?('When you rez') || new_card.text.include?('%s when it is rezzed' % new_card.title))
        new_card.rez_effect = true
      end

      if new_card.text && (new_card.text.match?(/trace(\[\d+| X| \d+)/i) || new_card.text.match?('<trace>'))
        new_card.performs_trace = true
      end

      # TODO(plural): Add these in as well
      # - click_ability / click_cost
      # - [credit] - credit cost or paid ability?
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

  def import_card_faces(cards)
    # Use a transaction since we are deleting the card face and mapping tables.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing card -> card face mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM cards_card_faces")
        puts 'Hit an error while deleting card -> card face mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      puts '  Clear out existing card face -> card subtype mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM card_faces_card_subtypes")
        puts 'Hit an error while deleting card face -> card subtype mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      puts '  Clear out existing card faces'
      unless ActiveRecord::Base.connection.delete("DELETE FROM card_faces")
        puts 'Hit an error while deleting card faces. rolling back.'
        raise ActiveRecord::Rollback
      end

      subtypes = CardSubtype.all.index_by(&:id)
      new_faces = []
      cards_to_card_faces = []
      card_faces_to_card_subtypes = []
      cards.each do |card|
        # Only generate faces for cards with multiple faces
        next if !card.key?('layout_id') || card['layout_id'].nil? || card['layout_id'] == 'normal'

        # The first face of each card is generated from its base stats
        new_face = CardFace.new(
          id: card["id"] + '_0',
          card_id: card["id"],
        )
        new_face.title = card["title"]
        new_face.stripped_title = card["stripped_title"]
        new_face.base_link = card["base_link"]
        new_face.advancement_requirement = card["advancement_requirement"]
        new_face.agenda_points = card["agenda_points"]
        new_face.cost = card["cost"]
        new_face.memory_cost = card["memory_cost"]
        new_face.strength = card["strength"]
        new_face.text = card["text"]
        new_face.stripped_text = card["stripped_text"]
        new_face.trash_cost = card["trash_cost"]
        new_face.is_unique = card["is_unique"]
        new_face.display_subtypes = flatten_subtypes(subtypes, card["subtypes"])
        new_faces << new_face
        cards_to_card_faces << {
          "card_id": card["id"],
          "card_face_id": new_face.id
        }
        unless card["subtypes"].nil?
          card["subtypes"].each do |s|
            card_faces_to_card_subtypes << {
              "card_face_id": new_face.id,
              "card_subtype_id": s
            }
          end
        end

        # The rest of the faces are generated from the explicitly-defined faces of the card
        # Missing attributes are assumed to be unchanged and are copied from the base stats
        i = 0
        card['faces'].each do |face|
          i += 1
          face_subtypes = face.key?("subtypes") ? face["subtypes"] : card["subtypes"]
          new_face = CardFace.new(
            id: card["id"] + '_' + i.to_s,
            card_id: card["id"],
          )
          new_face.title = face.key?("title") ? face["title"] : card["title"]
          new_face.stripped_title = face.key?("stripped_title") ? face["stripped_title"] : card["stripped_title"]
          new_face.base_link = face.key?("base_link") ? face["base_link"] : card["base_link"]
          new_face.advancement_requirement = face.key?("advancement_requirement") ? face["advancement_requirement"] : card["advancement_requirement"]
          new_face.agenda_points = face.key?("agenda_points") ? face["agenda_points"] : card["agenda_points"]
          new_face.cost = face.key?("cost") ? face["cost"] : card["cost"]
          new_face.memory_cost = face.key?("memory_cost") ? face["memory_cost"] : card["memory_cost"]
          new_face.strength = face.key?("strength") ? face["strength"] : card["strength"]
          new_face.text = face.key?("text") ? face["text"] : card["text"]
          new_face.stripped_text = face.key?("stripped_text") ? face["stripped_text"] : card["stripped_text"]
          new_face.trash_cost = face.key?("trash_cost") ? face["trash_cost"] : card["trash_cost"]
          new_face.is_unique = face.key?("is_unique") ? face["is_unique"] : card["is_unique"]
          new_face.display_subtypes = flatten_subtypes(subtypes, face_subtypes)
          new_faces << new_face
          cards_to_card_faces << {
            "card_id": card["id"],
            "card_face_id": new_face.id
          }
          unless face_subtypes.nil?
            face_subtypes.each do |s|
              card_faces_to_card_subtypes << {
                "card_face_id": new_face.id,
                "card_subtype_id": s
              }
            end
          end
        end
      end

      puts '  About to save %d card faces...' % new_faces.length
      num_faces = 0
      new_faces.each_slice(250) { |s|
        num_faces += s.length
        puts '  %d faces' % num_faces
        CardFace.import s, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
      }

      CardCardFace.import cards_to_card_faces, on_duplicate_key_update: { conflict_target: [ :card_id, :card_face_id ], columns: :all }
      CardFaceCardSubtype.import card_faces_to_card_subtypes, on_duplicate_key_update: { conflict_target: [ :card_face_id, :card_subtype_id ], columns: :all }
    end
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
        legacy_code: c['legacy_code']
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
        description: t['description'],
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
          "legacy_code": s["legacy_code"]
      }
    end
    CardSet.import printings, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
  end

  def import_printings(printings)
    card_sets = CardSet.all.index_by(&:id)

    new_printings = []
    printings.each { |printing|
      new_printings << Printing.new(
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
      puts '  Clear out existing illustrator -> printing mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM illustrators_printings")
        puts 'Hit an error while deleting illustrator -> printing mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      puts '  Clear out existing illustrators'
      unless ActiveRecord::Base.connection.delete("DELETE FROM illustrators")
        puts 'Hit an error while deleting illustrators. rolling back.'
        raise ActiveRecord::Rollback
      end

      illustrators = Set[]
      illustrators_to_printings = []
      illustrator_num_printings = {}
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
            if !illustrator_num_printings.key?(i)
              illustrator_num_printings[i] = 0
            end
            illustrator_num_printings[i] += 1
          }
        end
      }

      ill = []
      illustrators.each { |i|
        ill << {
          "id": text_to_id(i),
          "name": i,
          "num_printings": illustrator_num_printings[i]
        }
      }

      Illustrator.import ill, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
      IllustratorPrinting.import illustrators_to_printings, on_duplicate_key_update: { conflict_target: [ :illustrator_id, :printing_id ], columns: :all }
    end
  end

  # This function largely reflects `import_card_faces` but for printings
  # Instead of linking faces to subtypes, it links faces to illustrators
  def import_printing_faces(printings)
    # Use a transaction since we are deleting the printing face and mapping tables.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing printing -> printing face mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM printings_printing_faces")
        puts 'Hit an error while deleting printing -> printing face mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      puts '  Clear out existing printing face -> illustrator mappings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM printing_faces_illustrators")
        puts 'Hit an error while deleting printing face -> illustrator mappings. rolling back.'
        raise ActiveRecord::Rollback
      end

      puts '  Clear out existing printing faces'
      unless ActiveRecord::Base.connection.delete("DELETE FROM printing_faces")
        puts 'Hit an error while deleting printing faces. rolling back.'
        raise ActiveRecord::Rollback
      end

      illustrators = Illustrator.all.index_by(&:id)
      new_faces = []
      printings_to_printing_faces = []
      printing_faces_to_illustrators = []
      printings.each do |printing|
        # Only generate faces for printings with multiple faces
        next if !printing.key?('layout_id') || printing['layout_id'].nil? || printing['layout_id'] == 'normal'

        # The first face of each printing is generated from its base stats
        new_face = PrintingFace.new(
          id: printing["id"] + '_0',
          printing_id: printing["id"],
        )
        new_face.flavor = printing["flavor"]
        new_face.display_illustrators = printing["illustrator"]
        new_face.copy_quantity = printing["copy_quantity"]
        new_faces << new_face
        printings_to_printing_faces << {
          "printing_id": printing["id"],
          "printing_face_id": new_face.id
        }
        if new_face.display_illustrators then
          new_face.display_illustrators.split(', ').each { |i|
            printing_faces_to_illustrators << {
              "printing_face_id": new_face.id,
              "illustrator_id": text_to_id(i)
            }
          }
        end

        # The rest of the faces are generated from the explicitly-defined faces of the card
        # Missing attributes are assumed to be unchanged and are copied from the base stats
        i = 0
        printing['faces'].each do |face|
          i += 1
          new_face = PrintingFace.new(
            id: printing["id"] + '_' + i.to_s,
            printing_id: printing["id"],
          )
          new_face.flavor = face.key?("flavor") ? face["flavor"] : printing["flavor"]
          new_face.display_illustrators = face.key?("illustrator") ? face["illustrator"] : printing["illustrator"]
          new_face.copy_quantity = face.key?("copy_quantity") ? face["copy_quantity"] : printing["copy_quantity"]
          new_faces << new_face
          printings_to_printing_faces << {
            "printing_id": printing["id"],
            "printing_face_id": new_face.id
          }
          if new_face.display_illustrators then
            new_face.display_illustrators.split(', ').each { |i|
              printing_faces_to_illustrators << {
                "printing_face_id": new_face.id,
                "illustrator_id": text_to_id(i)
              }
            }
          end
        end
      end

      puts '  About to save %d printing faces...' % new_faces.length
      num_faces = 0
      new_faces.each_slice(250) { |s|
        num_faces += s.length
        puts '  %d faces' % num_faces
        PrintingFace.import s, on_duplicate_key_update: { conflict_target: [ :id ], columns: :all }
      }

      PrintingPrintingFace.import printings_to_printing_faces, on_duplicate_key_update: { conflict_target: [ :printing_id, :printing_face_id ], columns: :all }
      PrintingFaceIllustrator.import printing_faces_to_illustrators, on_duplicate_key_update: { conflict_target: [ :printing_face_id, :illustrator_id ], columns: :all }
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
              card_id: card
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

  def date_after_2018(date_str)
    m = date_str.match(/^(\d{4})-/)
    if m && m.captures.length == 1
      return m.captures[0].to_i > 2018
    end
    return false
  end

  def strip_if_not_nil(str)
    if str == nil
      return str
    end
    return str.strip
  end

  def import_rulings(rulings_json)
    rulings = []
    rulings_json.each { |r|
      rulings << Ruling.new(
        card_id: r['card_id'],
        question: strip_if_not_nil(r['question']),
        answer: strip_if_not_nil(r['answer']),
        text_ruling: strip_if_not_nil(r['text_ruling']),
        updated_at: r['date_update'],
        nsg_rules_team_verified: r['nsg_rules_team_verified'],
      )
    }

    # Use a transaction since we are deleting the restriction mapping table.
    ActiveRecord::Base.transaction do
      puts '  Clear out existing rulings'
      unless ActiveRecord::Base.connection.delete("DELETE FROM rulings")
        puts 'Hit an error while deleting rulings. Rolling back.'
        raise ActiveRecord::Rollback
      end
      Ruling.import rulings
    end

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

    puts 'Importing Printing Faces...'
    import_printing_faces(printings_json)

    puts 'Importing Card Faces...'
    import_card_faces(cards_json)

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

    puts 'Importing Rulings...'
    rulings_json = load_multiple_json_files(args[:json_dir] + '/rulings/*.json')
    import_rulings(rulings_json)

    puts 'Refreshing materialized view for restrictions...'
    Scenic.database.refresh_materialized_view(:unified_restrictions, concurrently: false, cascade: false)

    puts 'Refreshing materialized view for cards...'
    Scenic.database.refresh_materialized_view(:unified_cards, concurrently: false, cascade: false)

    puts 'Refreshing materialized view for printings...'
    Scenic.database.refresh_materialized_view(:unified_printings, concurrently: false, cascade: false)

    puts 'Done!'
  end
end
