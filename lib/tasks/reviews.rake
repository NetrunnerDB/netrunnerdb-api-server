require 'json'
require 'net/http'
require 'optparse'
require 'uri'

namespace :reviews do
  desc 'Imports review from NRDBc, currently storing usernames as strings instead of references'

  def retrieve_reviews
    url = URI('https://netrunnerdb.com/api/2.0/public/reviews')

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)

    response = http.request(request)

    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

    raise "Failed to retrieve decklists! Status code: #{response.code}"
  end
  task import: :environment do
    puts 'Importing Reviews from NetrunnerDB Classic'
    reviews_body = retrieve_reviews
    reviews_body['data'].each do |review|
      card_name = review['title']
      rev_body = review['ruling']
      username = review['user']
      comments = review['comments']
      card = Card.find_by(title: card_name)
      if card
        r = Review.new
        r.card = card
        r.username = username
        r.body = rev_body
        r.created_at = DateTime.parse(review['date_create'])
        r.updated_at = DateTime.parse(review['date_update'])
        r.save!

        # Hack for votes: generate filler entries in the join table
        ReviewVote.transaction do
          review['votes'].times do
            vote = ReviewVote.new
            vote.username = 'TBD_Future_Problem'
            vote.review = r
            vote.save!
          end
        end

        # Generate Comments for each deck
        ReviewComment.transaction do
          comments.each do |comment|
            c = ReviewComment.new
            c.username = comment['user']
            c.body = comment['comment']
            c.review = r
            c.created_at = comment['date_create']
            c.updated_at = comment['date_update']
            c.save!
          end
        end
      else
        puts "Missing Card entry with title: #{card_name}"
      end
    end
  end
end
