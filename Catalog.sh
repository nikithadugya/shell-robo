#!/bin/bash

# This script is for validating the user at 20 line no and then following manual documentation and write script accordingly at 35 line no and then installing.

R="\e[31m"
G="\e[32m"
Y="\[e33m"
Normal="\e[0m"


LOGS_FOLDER="/var/log/shell-robo"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 ) # $0 --> Current file name  --> 14-logs
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST="mongodb.daws.nikitha.fun"
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

# here we got error because if user already present then it should handle so writing if-else

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating System User"
else
    echo -e "User already exist.... $Y SKIPPING $N"
fi

mkdir -p /app  # If already directory is present then -p mentioning ignores and next if not there it creates
VALIDATE $? "Creating App Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "DOwnloading Catalog application"

cd /app 
VALIDATE $? "Changing to App Directory"
 
# Here we got error because if files already present in app folder then it throws error so before only we are deleting
rm -rf /app/*
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzip Catalog"

npm install &>>$LOG_FILE
VALIDATE $? "Install Dependencies"

# Here also we got error because now while executing script it is in /app folder so in app folder we don't have catalog.service we have thos in robo-shell directory so are using pwd it goes to present working directoy that means while excuting script it's present working directory is Robo-shop so catalog.service is present init

cp $SCRIPT_DIR/catalog.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl services"

systemctl daemon-reload
VALIDATE $? "demon reload"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enabling catalog"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MONGODB Client"

#Checking whether the schema catalogue already present in the database mongo to avoid duplicate
INDEX=$(mongosh mongodb.daws.nikitha.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalog')")
if[ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load Catalogue produvts i.e, Loading Schemas from backend to database"
else
    echo -e "Catalog products already loaded... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalog"



