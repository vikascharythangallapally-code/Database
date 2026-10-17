#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only --quiet -c"

run_sql() {
  $PSQL "$1" </dev/null
}

quote_sql() {
  printf "%s" "$1" | sed "s/'/''/g"
}

show_services() {
  run_sql "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"
echo

while true; do
  show_services
  read SERVICE_ID_SELECTED

  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=""
  else
    SERVICE_NAME=$(run_sql "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  fi

  if [[ -z "$SERVICE_NAME" ]]; then
    echo
    echo "I could not find that service. What would you like today?"
    continue
  fi

  echo
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  ESCAPED_PHONE=$(quote_sql "$CUSTOMER_PHONE")
  CUSTOMER_ID=$(run_sql "SELECT customer_id FROM customers WHERE phone = '$ESCAPED_PHONE'")

  if [[ -z "$CUSTOMER_ID" ]]; then
    echo
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    ESCAPED_NAME=$(quote_sql "$CUSTOMER_NAME")
    CUSTOMER_ID=$(run_sql "INSERT INTO customers (phone, name) VALUES ('$ESCAPED_PHONE', '$ESCAPED_NAME') RETURNING customer_id")
  else
    CUSTOMER_NAME=$(run_sql "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  fi

  echo
  echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  ESCAPED_TIME=$(quote_sql "$SERVICE_TIME")
  run_sql "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$ESCAPED_TIME')" >/dev/null

  echo
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  break
done