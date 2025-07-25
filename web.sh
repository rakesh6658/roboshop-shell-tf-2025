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
 dnf install nginx -y &>>$LOG_FILE
 validate $? "install nginx"
 systemctl enable nginx &>>$LOG_FILE
 validate $? "enable nginx"
systemctl start nginx &>>$LOG_FILE
validate $? "start nginx"
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
validate $? "removing default content in nginx"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOG_FILE
validate $? "download frontend content in nginx"
cd /usr/share/nginx/html &>>$LOG_FILE
validate $? "cd into /usr/share/nginx/html"
unzip /tmp/web.zip &>>$LOG_FILE
validate $? "unzip web.zip"
cp /home/ec2-user/roboshop-shell-2025/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>>$LOG_FILE
validate $? "copy roboshop.conf"
systemctl restart nginx &>>$LOG_FILE
validate $? "restart nginx"