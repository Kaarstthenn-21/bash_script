#!/bin/bash

# Crear la primera instancia EC2 con Apache
aws ec2 run-instances \
    --image-id ami-0715c1897453cabd1 \
    --instance-type t2.micro \
    --key-name bootcamp-app \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=ApacheInstance}]" \
    --region us-east-1 \
    --user-data "#!/bin/bash
                 yum update -y
                 yum install -y httpd
                 echo 'Bootcamp AWS Ignite 2023 Apache!' > /var/www/html/index.html
                 systemctl start httpd
                 systemctl enable httpd" &

# Crear la segunda instancia EC2 con Node.js
aws ec2 run-instances \
    --image-id ami-0715c1897453cabd1 \
    --instance-type t2.micro \
    --key-name bootcamp-app \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=NodeInstance}]" \
    --region us-east-1 \
    --user-data "#!/bin/bash
                 yum update -y
                 curl -sL https://rpm.nodesource.com/setup_14.x | bash -
                 yum install -y nodejs
                 echo 'console.log(\"Bootcamp AWS Ignite 2023 Apache!\");' > /home/ec2-user/helloworld.js
                 node /home/ec2-user/helloworld.js" &

# Crear la tercera instancia EC2 con Python
aws ec2 run-instances \
    --image-id ami-0715c1897453cabd1 \
    --instance-type t2.micro \
    --key-name bootcamp-app \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=PythonInstance}]" \
    --region us-east-1 \
    --user-data "#!/bin/bash
                 yum update -y
                 yum install -y python3
                 echo 'print(\"Bootcamp AWS Ignite 2023 Apache!\")' > /home/ec2-user/helloworld.py
                 python3 /home/ec2-user/helloworld.py" &