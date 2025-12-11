#!/bin/bash

# This script is for validating the user at 20 line no and then following manual documentation and write script accordingly at 35 line no and then installing.

R="\e[31m"
G="\e[32m"
Y="\[e33m"
Normal="\e[0m"


LOGS_FOLDER="/var/log/shell-robo"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 ) # $0 --> Current file name  --> 14-logs
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER  # -p means if directory is not there it creates if directory is there is keeps quiet
echo "Script started executed at: $(date)" | tee -a $LOG_FILE  # tee command appends the output printing of this command on mobexterm same in LOg file as well.
USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root(sudo) privilage"
    exit 1 #any number is failure other than 0
fi


VALIDATE(){
if [ $1 -ne 0 ]; then
    echo "Installation $2... $R FAILURE $N"
    exit 1
else
    echo "Installation $2 ... $G success $N"
fi
}

# follow manual documentation and write script accordingly like next 

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>LOG_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod
VALIDATE $? "Start MongoDB"
