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
 dnf module disable nodejs -y &>>$LOG_FILE
 validate $? "disable nodejs"
dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enable nodejs"
dnf install nodejs -y  &>>$LOG_FILE
validate $? "installing nodejs"
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
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOG_FILE
 validate $? "downloaded catalogue.zip in tmp "
 cd /app &>>$LOG_FILE
 validate $? "cd into app"
 unzip /tmp/catalogue.zip &>>$LOG_FILE
 validate $? "unzip into app directory"
 npm install &>>$LOG_FILE
 validate $? "installing dependencies"
 cp /home/ec2-user/roboshop-shell-tf-2025/catalogue.service   /etc/systemd/system/catalogue.service &>>$LOG_FILE
 validate $? "copying catalogue.service"
 systemctl daemon-reload &>>$LOG_FILE
validate $? "load the service"
systemctl enable catalogue &>>$LOG_FILE
validate $? "enable service"
systemctl start catalogue &>>$LOG_FILE
validate $? "start the service"
cp /home/ec2-user/roboshop-shell-tf-2025/mongo.repo  /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
validate $? "copying mongo.repo"
dnf install -y mongodb-mongosh &>>$LOG_FILE
validate $? "installing mongodb-mongosh"
mongosh --host mongodb.joindevops.store </app/schema/catalogue.js &>>$LOG_FILE
validate $? "loading schema"

