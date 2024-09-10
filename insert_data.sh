#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "truncate teams, games;")"
echo "$($PSQL "alter sequence games_game_id_seq restart with 1;")"
echo "$($PSQL "alter sequence teams_team_id_seq restart with 1;")"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #Inserting into teams
  if [[ $WINNER != "winner" || $OPPONENT != "opponent" ]]
  then
    #Get WINNER_ID
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    
    #If not there
    if [[ -z $WINNER_TEAM_ID ]]
    then
      #Insert RECORD
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) values('$WINNER');")
      echo $INSERT_TEAM_NAME inserted: $WINNER

      #Get WINNER_ID
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      echo $WINNER_TEAM_ID win: $WINNER
    fi
    
    #Get OPPONENT_ID
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    

    #If not there
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      #insert record
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) values('$OPPONENT');")
      echo $INSERT_TEAM_NAME inserted: $OPPONENT

      #Get OPPONENT_ID
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
      echo $OPPONENT_TEAM_ID Oppo: $OPPONENT
    fi

    #Inserting into games
    INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $INSERT_INTO_GAMES == 'INSERT 0 1' ]]
    then
      echo insered into games with, $WINNER, $YEAR
    fi

  fi

  
done
