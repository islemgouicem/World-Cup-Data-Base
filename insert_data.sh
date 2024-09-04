#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
($PSQL "TRUNCATE TABLE teams, games;")
($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;")
($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]] #skip first line
  then
    #add teams
    for TEAM in "$WINNER" "$OPPONENT"
    do
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      if [[ -z $TEAM_ID ]]
      then
        INSERTED_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
        if [[ $INSERTED_TEAM == "INSERT 0 1" ]]
        then 
          echo "inserted team: '$TEAM'"
        fi
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      fi
    done
    # filling games table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Inserted game: $WINNER vs $OPPONENT ($YEAR, $ROUND)"
    fi


  fi
done

# Do not change code above this line. Use the PSQL variable above to query your database.
