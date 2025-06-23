# netrunnerdb-api-server

API Server for NetrunnerDB

## Status & Timeline

This is experimental for now, but will be the seed for v2 of NRDB.

Public API functionality will be implemented first as v3 of the existing NRDB API.

## Dependencies

This depends on the data from https://github.com/NetrunnerDB/netrunner-cards-json.

The netrunner-cards-json is expected to be next to the folder with this
repository and accessible at `../netrunner-cards-json` to the application.

## For dev in VS Code.

This repository has a Devcontainer setup. To use it, first copy the database.yml file.

```sh
cp config/database.example.yml config/database.yml
```

If you open this folder in VS Code it should prompt you to use the devcontainer.

## For local dev with docker

If you have a device with apple silicon, do the following first (adapt the
platform based on your device and error message):

```sh
export DOCKER_DEFAULT_PLATFORM=linux/arm64/v8
```

```sh
echo "RAILS_ENV=development" > .env
cp config/database.example.yml config/database.yml
docker network create null_signal
docker compose build
docker compose -f docker-compose.yml -f docker-compose.override.init.yml up -d
```

Wait until `docker compose logs nrdb_api_server | tail` shows `Listening on http://0.0.0.0:3000`.

Test that `http://localhost:3000/api/docs/` loads in your browser. Afterwords,

```sh
docker compose up -d
```
Is enough to spin up the containers, unless you want to restart the db from scratch (use the above example with init.yml)

To run tests in your docker container, you will need to override the environment, like so:

```sh
docker compose exec -e RAILS_ENV=test nrdb_api_server bundle exec rspec
```

If the tests fail after the initial setup, then you may need to first seed the database:
```sh
docker compose exec -e RAILS_ENV=test bundle exec rails db:seed
```

## Getting Started

Once your server is running you can hit the api!
ex. `http://localhost:3000/api/v3/public/cards/sure_gamble`

You can find the full list of routes here:
`http://localhost:3000/rails/info/routes`

API Documentation will be available at `http://localhost:3000/api/docs/`.

Run `RAILS_ENV=test bundle exec rails db:reset` with `docker compose run` or in a
shell in the container to load the fixture data for the tests.

To re-generate API documentation (in test environment to ensure minimal changes) run:
```sh
docker compose run -e RAILS_ENV=test nrdb_api_server bundle exec rake docs:generate
```

## Tasks

If you are using docker, ensure that you are in a shell for the container before running these tasks.

### Importing Cards

To import cards from the `netrunner-cards-json` repository, first ensure that
it is checked out next to this directory, then run:

```sh
bundle exec rake cards:import
```

### Importing Decklists

To import decklists from NRDB Classic, use

```sh
bundle exec rake import_decklists:import[2024-11-09]
```
## Adding new entities

To add a new entity, follow this rough process:

1. Add a new migration with a command like `bundle exec rails g active_record:model CreateFoo`.
2. Add a new resource for the model, using the files in `app/resources/` as an example.
3. Update `config/routes.rb` to add a route for the resource.

## Adding attributes to entities

To add attributes to entites, follow this general process:

1. Add a new migration with a command like `bundle exec rails g active_record:migration AddFooToCardCycle`
2. Update the migration to add new fields and any indexes to the tables.  See the `db/migrate/` folder for examples.
3. If this is an attribute that needs to be updated for the Card or Printing objects, update the materialized views for those entities with the instructions below.
4. Update the models with any needed relationships.
5. Add the new attributes and any needed filters to the appropriate resource file in `app/resources/`.
6. If you have changes to the `search` filter syntax for `Cards` or `Printings`, update the search query builder in `lib/search_query_builder.rb` using the `card`, `printing`, or `both` functions as appropriate for the attribute.

## Updating materialized views

We use a number of materialized views to make certain things that would be large, multi-table joins into single table queries.

Materialized Views:

* unified_cards - powers the Card model.
* unified_printings - powers the Printing model.
* unified_restrictions - powers the UnifiedRestriction model.

To add new fields to these models, you need to generate a new version of the view, with the following command:

```shell
bundle exec rails generate scenic:view unified_cards --materialized
```

This will create a new migration file in `db/migrate/` and a new SQL file in `db/views/` with a version number in the filename.

Edit the new SQL file and run your migration as normal with `bundle exec rails db:migrate`.

The materialized views are refreshed as part of the `cards:import` task.
