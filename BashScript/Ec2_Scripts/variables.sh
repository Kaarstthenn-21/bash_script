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
APACHE_INSTALL_SCRIPT="\#\!/bin/bash\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ yum\ update\ -y\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ yum\ install\ -y\ httpd\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ echo\ \'Bootcamp\ AWS\ Ignite\ 2023\ Apache\!\'\ \>\ /var/www/html/index.html\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ systemctl\ start\ httpd\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ systemctl\ enable\ httpd\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#\ Rules\ firewall\n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ firewall-cmd\ --zone=public\ --add-service=http\ --permanent\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ firewall-cmd\ --zone=public\ --add-service=https\ --permanent\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ firewall-cmd\ --reload\ \ \#\ Recargar\ las\ reglas\ de\ firewall\n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#\ Configure\ SSL/TLS\ let\'s\ encrypt\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ amazon-linux-extras\ install\ epel\ -y\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ yum\ install\ certbot\ python2-certbot-apache\ -y\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ certbot\ --apache\ --non-interactive\ --agree-tos\ --email\ tu-email@ejemplo.com\ --domains\ tu-dominio.com\n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#Restart\ Server\n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ systemctl\ restart\ httpd\ \ \ \n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#\ Configure\ Security\ module\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ yum\ install\ mod_security\ -y\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ echo\ \"Include\ /etc/httpd/conf.d/mod_security.conf\"\ \>\>\ /etc/httpd/conf/httpd.conf\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ cat\ \<\<\ EOF\ \>\ /etc/httpd/conf.d/mod_security.conf\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRuleEngine\ On\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRequestBodyAccess\ On\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRule\ REQUEST_HEADERS:Content-Type\ \"text/xml\"\ \"id:\'200000\'\,phase:1\,t:none\,t:lowercase\,pass\,nolog\,ctl:requestBodyProcessor=XML\"\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRequestBodyLimit\ 10000000\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRequestBodyNoFilesLimit\ 64000\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRequestBodyInMemoryLimit\ 64000\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRequestBodyLimitAction\ Reject\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRule\ REQBODY_ERROR\ \"\!@eq\ 0\"\ \"id:\'200001\'\,phase:2\,t:none\,log\,deny\,status:400\,msg:\'XML\ request\ body\ is\ larger\ than\ allowed\'\"\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRule\ REQUEST_LINE\ \"\!\(OPTIONS\|GET\|HEAD\|POST\|PUT\|DELETE\|CONNECT\|TRACE\|PATCH\)\"\ \"id:\'200002\'\,phase:2\,t:none\,log\,deny\,status:405\,msg:\'Method\ is\ not\ allowed\'\"\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ SecRule\ REQUEST_HEADERS:User-Agent\ \"\(libwww-perl\|curl\|wget\|python\|nikto\|sqlmap\)\"\ \"id:\'200003\'\,phase:2\,t:none\,log\,deny\,status:400\,msg:\'User-Agent\ is\ not\ allowed\'\"\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ EOF\n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#\ Reiniciar\ servicio\ de\ Apache\ para\ aplicar\ los\ cambios\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ systemctl\ restart\ httpd\ \n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#\ Configurar\ seguridad\ de\ Apache\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ echo\ \"ServerTokens\ Prod\"\ \>\>\ /etc/httpd/conf/httpd.conf\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ echo\ \"ServerSignature\ Off\"\ \>\>\ /etc/httpd/conf/httpd.conf\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#\ Configurar\ módulo\ correspondiente\ a\ PHP\ \(ejemplo\)\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ yum\ install\ php\ php-mysql\ -y\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ systemctl\ restart\ httpd\n\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \#\ Configurar\ módulo\ correspondiente\ a\ Node.js\ \(ejemplo\)\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ curl\ -sL\ https://rpm.nodesource.com/setup_14.x\ \|\ bash\ -\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ yum\ install\ nodejs\ -y\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ systemctl\ restart\ httpd"

# "#!/bin/bash
#                  yum update -y
#                  yum install -y httpd
#                  echo 'Bootcamp AWS Ignite 2023 Apache!' > /var/www/html/index.html
#                  systemctl start httpd
#                  systemctl enable httpd

#                  # Rules firewall

#                  firewall-cmd --zone=public --add-service=http --permanent
#                  firewall-cmd --zone=public --add-service=https --permanent
#                  firewall-cmd --reload  # Recargar las reglas de firewall

#                  # Configure SSL/TLS let's encrypt
#                  amazon-linux-extras install epel -y
#                  yum install certbot python2-certbot-apache -y
#                  certbot --apache --non-interactive --agree-tos --email tu-email@ejemplo.com --domains tu-dominio.com

#                  #Restart Server

#                  systemctl restart httpd

#                  # Configure Security module
#                  yum install mod_security -y
#                  echo "Include /etc/httpd/conf.d/mod_security.conf" >> /etc/httpd/conf/httpd.conf

#                  cat << EOF > /etc/httpd/conf.d/mod_security.conf
#                  SecRuleEngine On
#                  SecRequestBodyAccess On
#                  SecRule REQUEST_HEADERS:Content-Type "text/xml" "id:'200000',phase:1,t:none,t:lowercase,pass,nolog,ctl:requestBodyProcessor=XML"
#                  SecRequestBodyLimit 10000000
#                  SecRequestBodyNoFilesLimit 64000
#                  SecRequestBodyInMemoryLimit 64000
#                  SecRequestBodyLimitAction Reject
#                  SecRule REQBODY_ERROR "!@eq 0" "id:'200001',phase:2,t:none,log,deny,status:400,msg:'XML request body is larger than allowed'"
#                  SecRule REQUEST_LINE "!(OPTIONS|GET|HEAD|POST|PUT|DELETE|CONNECT|TRACE|PATCH)" "id:'200002',phase:2,t:none,log,deny,status:405,msg:'Method is not allowed'"
#                  SecRule REQUEST_HEADERS:User-Agent "(libwww-perl|curl|wget|python|nikto|sqlmap)" "id:'200003',phase:2,t:none,log,deny,status:400,msg:'User-Agent is not allowed'"
#                  EOF

#                  # Reiniciar servicio de Apache para aplicar los cambios
#                  systemctl restart httpd

#                  # Configurar seguridad de Apache
#                  echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf
#                  echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf

#                  # Configurar módulo correspondiente a PHP (ejemplo)
#                  yum install php php-mysql -y
#                  systemctl restart httpd

#                  # Configurar módulo correspondiente a Node.js (ejemplo)
#                  curl -sL https://rpm.nodesource.com/setup_14.x | bash -
#                  yum install nodejs -y
#                  systemctl restart httpd
#                  "

#Variables para obtener Ip actual
MY_IP=$(curl -s http://checkip.amazonaws.com)

#Variables Puertos
PORT_SSH=22
PORT_HTTP=80
PORT_HTTPS=443

#Variables para EBS
NEW_SIZE=10
NEW_VOLUME_TYPE="gp2"
