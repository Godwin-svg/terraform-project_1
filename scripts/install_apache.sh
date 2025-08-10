#!/bin/bash
yum update -y
yum install httpd -y
echo "this instance is: $(HOSTNAME)" > /var/www/html/index.html 
systemct enable httpd -y 
systemctl start httpd -y 