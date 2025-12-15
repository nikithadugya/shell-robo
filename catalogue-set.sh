#!/bin/bash

# This script is for validating the user at 20 line no and then following manual documentation and write script accordingly at 35 line no and then installing.
set -euo pipefail

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR # Here $LINENO is a special variable that gives line no of error occured and BASH_COMMAND gives the exact error word and while executing shell checks ERR and in code it comes here and checks trap command   

R="\e[31m"
G="\e[32m"
Y="\[e33m"
Normal="\e[0m"


LOGS_FOLDER="/var/log/shell-robo"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 ) # $0 --> Current file name  --> 14-logs
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST="mongodb.dawsnikitha.fun"
SCRIPT_DIR="$PWD"
mkdir -p $LOGS_FOLDER  # -p means if directory is not there it creates if directory is there is keeps quiet
echo "Script started executed at: $(date)" | tee -a $LOG_FILE  # tee command appends the output printing of this command on mobexterm same in LOg file as well.
USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root(sudo) privilage"
    exit 1 #any number is failure other than 0
fi

# follow manual documentation and write script accordingly like next 

### NODEJS ###

dnf module disable nodejs -y &>>$LOG_FILE
# IF WE USE SET COMMAND TO SEE ERRORS THEN USE ECHO FOR EVERY LINE TO SEE THE STATUS
echo -e "Disabling the nodejs $G SUCCESS $N"
dnf module enable nodejs:20 -y &>>$LOG_FILE

dnf install nodejs -y

# here we got error because if user already present then it should handle so writing if-else

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "User already exist.... $Y SKIPPING $N"
fi

mkdir -p /app  # If already directory is present then -p mentioning ignores and next if not there it creates

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE

cd /app 
 
# Here we got error because if files already present in app folder then it throws error so before only we are deleting
rm -rf /app/*
unzip /tmp/catalogue.zip &>>$LOG_FILE

npm install &>>$LOG_FILE

# Here also we got error because now while executing script it is in /app folder so in app folder we don't have catalog.service we have thos in robo-shell directory so are using pwd it goes to present working directoy that means while excuting script it's present working directory is Robo-shop so catalog.service is present init

cp $SCRIPT_DIR/catalog.service /etc/systemd/system/catalogue.service

systemctl daemon-reload

systemctl enable catalogue &>>$LOG_FILE

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$LOG_FILE

#Checking whether the schema catalogue already present in the database mongo to avoid duplicate
INDEX=$(mongosh mongodb.dawsnikitha......fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalog')")  #Given error here wantedly
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "Catalog products already loaded... $Y SKIPPING $N"
fi

systemctl restart catalogue



