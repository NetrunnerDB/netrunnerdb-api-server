# netrunnerdb-api-server

API Server for NetrunnerDB

## Status & Timeline

This is experimental for now, but will be the seed for v2 of NRDB.

Public API functionality will be implemented first as v3 of the existing NRDB API.

## Dependencies

This depends on the data from https://github.com/NetrunnerDB/netrunner-cards-json

## For local dev with docker

```
echo "RAILS_ENV=development" > .env
cp config/database.example.yml config/database.yml
docker compose -f docker-compose.yml -f docker-compose.override.init.yml up -d
```
Wait until `docker compose logs nrdb_api_server | tail` shows `Listening on http://0.0.0.0:3000`.

Test that `http://localhost:3000/api/docs/` loads in your browser. Afterwords,

```
docker compose up -d
```
Is enough to spin up the containers, unless you want to restart the db from scratch (use the above example with init.yml)

To run tests in your docker container, you will need to override the environment, like so:
```
docker compose exec -e RAILS_ENV=test nrdb_api_server rails test
```

## Getting Started

Once your server is running you can hit the api!
ex. `http://localhost:3000/api/v3/public/cards/sure_gamble`

You can find the full list of routes here:
`http://localhost:3000/rails/info/routes`

API Documentation will be available at `http://localhost:3000/api/docs/`.

To re-generate API documentation (in test environment to ensure minimal changes) run:
```
docker compose run -e RAILS_ENV=test nrdb_api_server bundle exec rake docs:generate
```
