#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$NAME'")
if [[ -z $USER_ID ]]
then
  echo Welcome, $NAME! It looks like this is your first time here.
  INSERT_NAME=$($PSQL "INSERT INTO users(username) VALUES('$NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$NAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(game_result) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
MY_RANDOM_NUMBER=$(( $RANDOM%1000 + 1))
STEPS=0
USER_GUESS=0
echo Guess the secret number between 1 and 1000:
while [[ $MY_RANDOM_NUMBER != $USER_GUESS ]]
do
  read USER_GUESS
  ((++STEPS))
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $USER_GUESS -gt $MY_RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $USER_GUESS -lt $MY_RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
done
echo "You guessed it in $STEPS tries. The secret number was $MY_RANDOM_NUMBER. Nice job!"
INSERT_GAME_DATA=$($PSQL "INSERT INTO games(user_id, game_result) VALUES($USER_ID, $STEPS)")
