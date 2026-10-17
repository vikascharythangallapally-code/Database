#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_values=""
game_values=""

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year == "year" ]]
  then
    continue
  fi

  team_values+="${team_values:+,}('$winner'),('$opponent')"
  game_values+="${game_values:+,}($year, '$round', '$winner', '$opponent', $winner_goals, $opponent_goals)"
done < "$(dirname "$0")/games.csv"

$PSQL "INSERT INTO teams(name) VALUES $team_values ON CONFLICT (name) DO NOTHING"
$PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
SELECT game_data.year, game_data.round, winner.team_id, opponent.team_id,
       game_data.winner_goals, game_data.opponent_goals
FROM (VALUES $game_values) AS game_data(year, round, winner, opponent, winner_goals, opponent_goals)
JOIN teams AS winner ON winner.name = game_data.winner
JOIN teams AS opponent ON opponent.name = game_data.opponent"
