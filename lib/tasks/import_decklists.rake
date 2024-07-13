require 'json'
require 'net/http'
require 'optparse'
require 'uri'

namespace :import_decklists do
  desc 'import card data - json_dir defaults to /netrunner-cards-json/v2/ if not specified.'

  def retrieve_decklists(date)
    url = URI("https://netrunnerdb.com/api/2.0/public/decklists/by_date/%s" % date)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      return JSON.parse(response.body)
    else
      raise "Failed to retrieve decklists! Status code: #{response.code}"
    end
  end

  task :import, [:date] => [:environment] do |t, args|
    args.with_defaults(:date => '/netrunner-cards-json/v2/')

    puts 'Import decklists for date %s...' % args[:date]

    printings = Printing.all
    printing_to_card = {}
    printings.each do |printing|
      printing_to_card[printing.id] = printing.card_id
    end

    cards = Card.all
    cards_by_id = {}
    cards.each do |card|
      cards_by_id[card.id] = card
    end

    retrieve_decklists(args[:date])['data'].each do |decklist|
      puts 'Importing "%s" by %s (%s)' % [decklist['name'], decklist['user_name'], decklist['uuid']]

      d = Decklist.find_or_initialize_by(id: decklist['uuid'])
      d.name = decklist['name']
      d.user_id = decklist['user_name']

      d.created_at = DateTime.parse(decklist['date_creation'])
      d.updated_at = DateTime.parse(decklist['date_update'])
      d.notes = decklist['description']

      decklist['cards'].each do |printing_id, quantity|
        card = cards_by_id[printing_to_card[printing_id]]
        if ['corp_identity', 'runner_identity'].include?(card.card_type_id)
            d.identity_card_id = card.id
            d.side_id = card.side_id
        end
      end

      d.save!

      # To allow overwriting, clear out the existing cards.
      d.decklist_cards.delete_all
      decklist['cards'].each do |printing_id, quantity|
        card = cards_by_id[printing_to_card[printing_id]]
        # Do not write identity cards to the decklist_cards table.
        if !['corp_identity', 'runner_identity'].include?(card.card_type_id)
          d.decklist_cards << d.decklist_cards.build(card_id: printing_to_card[printing_id], quantity: quantity)
        end
      end
    end
  end
end
