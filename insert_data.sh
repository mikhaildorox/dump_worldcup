#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != winner ]] 
  then
    # get team_id 
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #if not found 
    if [[ -z $TEAM_ID ]]
    then 
      #insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $WINNER 
      fi

      #get new team
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
  fi

  if [[ $OPPONENT != opponent ]] 
  then
    # get team_id 
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #if not found 
    if [[ -z $TEAM_ID ]]
    then 
      #insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $OPPONENT 
      fi

      #get new team
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi

  if [[ $WINNER != $OPPONENT ]]
  then
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") 

    #get new game
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$TEAM_ID_WINNER AND opponent_id=$TEAM_ID_OPPONENT")
    # if not found
    if [[ -z $GAME_ID ]]
    then
      
      if [[ $TEAM_ID_WINNER != $TEAM_ID_OPPONENT ]]
      then
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', '$TEAM_ID_WINNER', '$TEAM_ID_OPPONENT', $WINNER_GOALS, $OPPONENT_GOALS)")
        if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
        then
          echo Inserted into games, $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS
        fi
          #get new game
        GAME_ID=$($PSQL "SELECT game_id FROM games WHERE '$WINNER'!='$OPPONENT' ")
      fi
    fi
  fi  
done  

