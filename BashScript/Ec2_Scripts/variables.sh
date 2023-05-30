# Variables Security Group
GROUP_NAME="apache-securitygroup"
DESCRIPTION="Apache security group"
VPC_ID="vpc-0d2685a79a76979a8"

#Variables para EC2 - Amazon linux
AWS_REGION="us-east-1"
INSTANCE_TYPE="t2.micro"
KEY_PAIR_NAME="apache-key"
SECURITY_GROUP_NAME=$GROUP_NAME
AMI_ID="ami-0715c1897453cabd1"
APACHE_INSTALL_SCRIPT="#!/bin/bash
                 yum update -y
                 yum install -y httpd
                 echo 'Bootcamp AWS Ignite 2023 Apache!' > /var/www/html/index.html
                 systemctl start httpd
                 systemctl enable httpd"

#Variables para obtener Ip actual
MY_IP=$(curl -s http://checkip.amazonaws.com)

#Variables Puertos
PORT_SSH=22
PORT_HTTP=80
PORT_HTTPS=443