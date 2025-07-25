#!/bin/bash
LOGS_DIR=/tmp
scriptname=$0
DATE=$(date +%F-%H-%M-%S)
LOG_FILE=$LOGS_DIR/$scriptname-$DATE.log
R="\e[0;31m"
G="\e[0;32m"
Y="\e[0;33m"
N="\e[0m"
userid=$(id -u)
if [ $userid -ne 0 ]
then
 echo "not a root user proceed with root access"
 exit 1
 fi
 validate(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2... $R failure $N"
    else
    echo -e "$2.... $G success $N"
    fi
 }
 dnf install maven -y &>>$LOG_FILE
 validate $? "installing maven"
 id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then 
useradd roboshop &>>$LOG_FILE
validate $? "adding user roboshop"
else 
echo "user roboshop exists"
fi
DIR="/app"

if [ ! -d "$DIR" ]; then
    echo "Directory does not exist. Creating..."
    mkdir -p "$DIR" &>>$LOG_FILE
    validate $? "created app directory"
else
    echo "$DIR exists."
fi
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
 validate $? "downloaded shipping.zip in tmp "
 rm -rf /app/*
 cd /app &>>$LOG_FILE
 validate $? "cd into app"
 unzip -o /tmp/shipping.zip &>>$LOG_FILE
 validate $? "unzip into app directory"
 mvn clean package &>>$LOG_FILE
 validate $? "installing dependencies"
 mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
 validate $? "moving shipping.jar"
 cp /home/ec2-user/roboshop-shell-2025/shipping.service   /etc/systemd/system/shipping.service &>>$LOG_FILE
 validate $? "copying shipping.service"
 systemctl daemon-reload &>>$LOG_FILE
validate $? "load the service"
systemctl enable shipping &>>$LOG_FILE
validate $? "enable service"
systemctl start shipping &>>$LOG_FILE
validate $? "start the service"
dnf install mysql -y  &>>$LOG_FILE
validate $? "installing mysql-clicent"
 mysql -h mysql.joindevops.store -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
 validate $? "loading schema.sql"
 mysql -h mysql.joindevops.store -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE 
validate $? "loading app-user.sql"
 mysql -h mysql.joindevops.store -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
 validate $? "loading master-data.sql"
systemctl restart shipping &>>$LOG_FILE
validate $? "restarting shipping"

