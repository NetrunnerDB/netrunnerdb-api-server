require 'rake'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
if Rails.env != 'test'
  puts 'Not seeding any data for non-test environment.'
else
  puts "It's me!  The test environment!  Let's seed, friends!"
#  Rails.application.load_tasks
  Rake::Task["db:fixtures:load"].invoke
end