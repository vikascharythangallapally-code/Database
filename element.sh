#!/bin/bash

if [[ -z "$1" ]]; then
  printf 'Please provide an element as an argument.\n'
  exit 0
fi

escaped_argument=$(printf '%s' "$1" | sed "s/'/''/g")
PSQL=(psql --username=freecodecamp --dbname=periodic_table --tuples-only --no-align --field-separator='|')
element_data=$("${PSQL[@]}" -c "SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius FROM elements JOIN properties USING (atomic_number) JOIN types USING (type_id) WHERE elements.atomic_number::text = '$escaped_argument' OR lower(elements.symbol) = lower('$escaped_argument') OR lower(elements.name) = lower('$escaped_argument');" 2>/dev/null)

if [[ -z "$element_data" ]]; then
  printf 'I could not find that element in the database.\n'
  exit 0
fi

IFS='|' read -r atomic_number name symbol type atomic_mass melting_point boiling_point <<< "$element_data"
printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$atomic_number" "$name" "$symbol" "$type" "$atomic_mass" "$name" "$melting_point" "$boiling_point"
