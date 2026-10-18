#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read -r USERNAME

USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -n $USER_EXISTS ]]; then
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
while read -r GUESS; do
  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
  if [[ $GUESS == -* ]]; then
    GUESS_VALUE=$((-10#${GUESS#-}))
  else
    GUESS_VALUE=$((10#$GUESS))
  fi

  if (( GUESS_VALUE < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS_VALUE > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    break
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
$PSQL "INSERT INTO games(username, number_of_guesses) VALUES('$USERNAME', $NUMBER_OF_GUESSES)" > /dev/null