#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DROP_TABLES=$($PSQL "DROP TABLE IF EXISTS users, games;")
if [[ $DROP_TABLES == "DROP TABLE" ]]
then 
  echo -e "\nDroped tables.\n"
fi

# create users table
CREATE_TABLE_USERS=$($PSQL "CREATE TABLE users(user_id SERIAL PRIMARY KEY, username VARCHAR(22) NOT NULL);")
if [[ $CREATE_TABLE_USERS == "CREATE TABLE" ]]
then 
  echo -e "\nCreated users table.\n"
fi

# create games table
CREATE_TABLE_GAMES=$($PSQL "CREATE TABLE games(game_id SERIAL, guesses INT NOT NULL, secret_number INT NOT NULL, user_id INT NOT NULL, PRIMARY KEY (game_id), CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id));")
if [[ $CREATE_TABLE_GAMES == "CREATE TABLE" ]]
then 
  echo -e "\nCreated games table.\n"
fi
