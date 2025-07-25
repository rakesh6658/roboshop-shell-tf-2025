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
 dnf install python3 gcc python3-devel -y &>>$LOG_FILE
 validate $? "installing python"
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
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
 validate $? "downloaded payment.zip in tmp "
 rm -rf /app/*
 cd /app &>>$LOG_FILE
 validate $? "cd into app"
 unzip -o /tmp/payment.zip &>>$LOG_FILE
 validate $? "unzip into app directory"
 pip3 install -r requirements.txt &>>$LOG_FILE
 validate $? "installing dependencies"
 cp /home/ec2-user/roboshop-shell-2025/payment.service   /etc/systemd/system/payment.service &>>$LOG_FILE
 validate $? "copying payment.service"
 systemctl daemon-reload &>>$LOG_FILE
validate $? "load the service"
systemctl enable payment &>>$LOG_FILE
validate $? "enable service"
systemctl start payment &>>$LOG_FILE
validate $? "start the service"
