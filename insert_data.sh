#! /bin/bash

if [[ $1 == "test" ]]
then
PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Before executing the script, you need to create a worldcup database
# create database worldcup;

TEAMS=$($PSQL "select * from pg_tables where tablename = 'teams'")
if [[ $TEAMS > 0 ]]
then
$PSQL "drop table teams cascade"
fi

GAMES=$($PSQL "select * from pg_tables where tablename = 'games'")
if [[ $GAMES > 0 ]]
then
$PSQL "drop table games cascade"
fi

$PSQL "create table teams()"
$PSQL "create table games()"
$PSQL "alter table teams add team_id serial primary key"
$PSQL "alter table teams add name varchar(50) unique not null"
$PSQL "alter table games add game_id serial primary key"
$PSQL "alter table games add year int not null"
$PSQL "alter table games add round varchar(50) not null"
$PSQL "alter table games add winner_id int not null"
$PSQL "alter table games add opponent_id int not null"
$PSQL "alter table games add winner_goals int not null"
$PSQL "alter table games add opponent_goals int not null"
$PSQL "alter table games add foreign key(winner_id) references teams(team_id)"
$PSQL "alter table games add foreign key(opponent_id) references teams(team_id)"

CSV_FILE="games.csv"
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
if [[ "$year" != "year" ]]
then
WINNERID=$($PSQL "WITH ins AS ( INSERT INTO teams (name) VALUES ('$winner') ON CONFLICT (name) DO NOTHING RETURNING team_id )
SELECT team_id FROM ins UNION ALL SELECT team_id FROM teams WHERE name = '$winner' LIMIT 1;" )
OPPONENTID=$($PSQL "WITH ins AS ( INSERT INTO teams (name) VALUES ('$opponent') ON CONFLICT (name) DO NOTHING RETURNING team_id )
SELECT team_id FROM ins UNION ALL SELECT team_id FROM teams WHERE name = '$opponent' LIMIT 1;")
$PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
values($year, '$round', $WINNERID, $OPPONENTID, $winner_goals, $opponent_goals)"
fi
done < "$CSV_FILE"
