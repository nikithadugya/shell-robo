#!/bin/bash

# This script is for validating the user at 20 line no and then following manual documentation and write script accordingly at 35 line no and then installing.

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


VALIDATE(){
if [ $1 -ne 0 ]; then
    echo -e "Installation $2... $R FAILURE $N"
    exit 1
else
    echo -e "Installation $2 ... $G success $N"
fi
}

# follow manual documentation and write script accordingly like next 

### NODEJS ###

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx"

dnf install nginx -y
VALIDATE $? "Installing nginx"

# here we got error because if user already present then it should handle so writing if-else

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "DOwnloading frontend application"

cd /usr/share/nginx/html 
 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzip Catalogue"

# Here also we got error because now while executing script it is in /app folder so in app folder we don't have catalog.service we have thos in robo-shell directory so are using pwd it goes to present working directoy that means while excuting script it's present working directory is Robo-shop so catalog.service is present init

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copy systemctl services"

systemctl restart frontend
VALIDATE $? "Restarted frontend"



