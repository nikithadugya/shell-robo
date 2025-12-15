#!/bin/bash

# This script is for validating the user at 20 line no and then following manual documentation and write script accordingly at 35 line no and then installing.

R="\e[31m"
G="\e[32m"
Y="\[e33m"
Normal="\e[0m"


LOGS_FOLDER="/var/log/shell-robo"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 ) # $0 --> Current file name  --> 14-logs
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
mkdir -p $LOGS_FOLDER  # -p means if directory is not there it creates if directory is there is keeps quiet
echo "Script started executed at: $(date)" | tee -a $LOG_FILE  # tee command appends the output printing of this command on mobexterm same in LOg file as well.
USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root(sudo) privilage"
    exit 1 #any number is failure other than 0
fi


VALIDATE(){
if [ $1 -ne 0 ]; then
    echo -e "Installation $2... $R FAILURE $N"
    exit 1
else
    echo -e "Installation $2 ... $G success $N"
fi
}

dnf install mysql-server -y
VALIDATE $? "Installing Mysql Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Started MySQL Server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up Root password"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"

