#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Script to randomly generate a number that users have to guess

echo -e "\n~~~~~~~~Number guessing game~~~~~~~~\n"

GET_USER() {
  # promp user for username
  echo -e "\nEnter your username:"
  read INPUT_USERNAME

  # get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$INPUT_USERNAME';")

  # if not found
  if [[ -z $USER_ID ]]
  then
    echo -e "\nWelcome, $INPUT_USERNAME! It looks like this is your first time here.\n"
    # add user 
    INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES ('$INPUT_USERNAME');")
  else   
    # get number of games played and best game
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$INPUT_USERNAME';")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games LEFT JOIN users USING(user_id) WHERE username='$INPUT_USERNAME';")
    echo Welcome back, $INPUT_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  fi

  GUESS_NUMBER
}  

GUESS_NUMBER() {
  # generate random_number
  SECRET_NUMBER=$((1 + RANDOM % 1000))
  echo $SECRET_NUMBER
  # count number of gueseses
  GUESSES=0

  # get number from user
  echo -e "\nGuess the secret number between 1 and 1000:\n"
  read NUMBER
  GUESSES=$((GUESSES + 1)) 

  until [[ $NUMBER -eq $SECRET_NUMBER ]]    
  do 
    # if not integer 
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]  
    then
      echo That is not an integer, guess again:
      read NUMBER
      GUESSES=$(($GUESSES + 1)) 
    else
      #  if input is higher than the secret number
      if [[ $NUMBER -gt $SECRET_NUMBER ]]
      then
        GUESSES=$(($GUESSES + 1))
        echo -e "\nIt's lower than that, guess again:"
        read NUMBER
      else
        #  if input is lower than the secret number
        GUESSES=$(($GUESSES + 1))      
        echo -e "\nIt's higher than that, guess again:"
        read NUMBER
      fi    
    fi
  done
  
  if [[ $NUMBER == $SECRET_NUMBER ]]
  then
    # if secret number is guessed
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$INPUT_USERNAME';")
    INSERT_GAME=$($PSQL "INSERT INTO games (guesses, secret_number, user_id) VALUES ($GUESSES, $SECRET_NUMBER, $USER_ID);")
    if [[ $INSERT_GAME == 'INSERT 0 1' ]]
    then
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"  
      exit 0
    fi	
  fi 
}
GET_USER
