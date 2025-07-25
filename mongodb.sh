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
 cp /home/ec2-user/roboshop-shell-tf-2025/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
 validate $? "copying of mongo.repo"

 dnf install mongodb-org -y &>>$LOG_FILE
 validate $? "installing mongodb"
 systemctl enable mongod &>>$LOG_FILE
 validate $? "enabling mongodb"
 systemctl start mongod &>>$LOG_FILE
  validate $? "starting mongodb"
 sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
 validate $? "changing ip address mongodb"

 systemctl restart mongod &>>$LOG_FILE
 validate $? "restarting mongodb"
 


