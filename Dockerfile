FROM ruby:3.1

RUN apt-get update -qq && apt-get install -y postgresql-client

RUN gem install rails

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/nrdb-api

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN pwd

COPY Gemfile Gemfile.lock ./

RUN bundle install

ENTRYPOINT ["./entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
