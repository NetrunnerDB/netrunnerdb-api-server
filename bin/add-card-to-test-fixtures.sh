#!/bin/sh

# Adds a v2 card to the test fixtures cards.yml file, with necessary transformations. 

set -e
set -u

CARD_ID=$1

echo "" >> test/fixtures/cards.yml

echo "${CARD_ID}:" >> test/fixtures/cards.yml

cat ../netrunner-cards-json/v2/cards/${CARD_ID}.json | \
  grep -v -E '^({|})' | \
  perl -pne 's/,$//g; s/^  "/  /; s/": /: /' |\
  grep -v '^  subtypes:' \
  >> test/fixtures/cards.yml
