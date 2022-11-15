require 'rake'

# Load up all the fixtures when seeding in the test environment.
# For the public data, this works great because we can rely on that
# data for all the tests and the API doc generation.
if Rails.env == 'test'
  Rake::Task["db:fixtures:load"].invoke
end
