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
 cp /home/ec2-user/roboshop-shell-2025/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
 validate $? "copying rabbitmq.repo"
 dnf install rabbitmq-server -y &>>$LOG_FILE
validate $? "installing rabbitmq"
 systemctl enable rabbitmq-server &>>$LOG_FILE
validate $? "enable rabbitmq"
systemctl start rabbitmq-server &>>$LOG_FILE
validate $? "start rabbitmq"
rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
validate $? "adding uuser roboshop"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
validate $? "setting permissions"