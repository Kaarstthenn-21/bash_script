
source ./variables.sh


if aws ec2 describe-security-groups --group-names "$GROUP_NAME" >/dev/null 2>&1; then
  echo "El grupo de seguridad $GROUP_NAME ya existe. No es necesario crearlo."
else
  # Crear el grupo de seguridad
  GROUP_ID=$(aws ec2 create-security-group \
    --group-name "$GROUP_NAME" \
    --description "$DESCRIPTION" \
    --vpc-id "$VPC_ID" \
    --output text \
    --query 'GroupId')

  echo "Se ha creado el grupo de seguridad $GROUP_ID ($GROUP_NAME)."
fi

GROUP_DESCRIPTION=$(aws ec2 describe-security-groups --group-names "$GROUP_NAME")


if echo "$GROUP_DESCRIPTION" | grep -q "\"FromPort\": $PORT_SSH,"; then
  echo "El puerto $PORT_SSH está configurado en el grupo de seguridad $GROUP_NAME."
else
  # Habilitar el acceso SSH (puerto 22)
  aws ec2 authorize-security-group-ingress \
    --group-id "$GROUP_ID" \
    --protocol tcp \
    --port $PORT_SSH \
    --cidr $MY_IP/32
  echo "Se ha habilitado el acceso SSH (puerto 22) en el grupo de seguridad $GROUP_ID ($GROUP_NAME)."
fi

if echo "$GROUP_DESCRIPTION" | grep -q "\"FromPort\": $PORT_HTTP,"; then
  echo "El puerto $PORT_HTTP está configurado en el grupo de seguridad $GROUP_NAME."
else
  # Habilitar el acceso HTTP (puerto 80)
  aws ec2 authorize-security-group-ingress \
    --group-id "$GROUP_ID" \
    --protocol tcp \
    --port $PORT_HTTP \
    --cidr $MY_IP/32

  echo "Se ha habilitado el acceso HTTP (puerto 80) en el grupo de seguridad $GROUP_ID ($GROUP_NAME)."
fi

if echo "$GROUP_DESCRIPTION" | grep -q "\"FromPort\": $PORT_HTTPS,"; then
  echo "El puerto $PORT_HTTPS está configurado en el grupo de seguridad $GROUP_NAME."
else
  # Habilitar el acceso HTTPS (puerto 443)
  aws ec2 authorize-security-group-ingress \
    --group-id "$GROUP_ID" \
    --protocol tcp \
    --port $PORT_HTTPS \
    --cidr $MY_IP/32

  echo "Se ha habilitado el acceso HTTPS (puerto 443) en el grupo de seguridad $GROUP_ID ($GROUP_NAME)."
fi

# Crear la instancia de EC2
INSTANCE_ID=$(aws ec2 run-instances \
  --region $AWS_REGION \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_PAIR_NAME \
  --security-groups $SECURITY_GROUP_NAME \
  --user-data "$APACHE_INSTALL_SCRIPT" \
  --output text \
  --query 'Instances[0].InstanceId')

echo "La instancia de EC2 ($INSTANCE_ID) se está creando..."

# Esperar hasta que la instancia esté en estado 'running'
aws ec2 wait instance-running --region $AWS_REGION --instance-ids $INSTANCE_ID

echo "La instancia de EC2 ($INSTANCE_ID) se ha creado exitosamente."

# Obtener la dirección IP pública de la instancia
PUBLIC_IP=$(aws ec2 describe-instances \
  --region $AWS_REGION \
  --instance-ids $INSTANCE_ID \
  --output text \
  --query 'Reservations[0].Instances[0].PublicIpAddress')

echo "La instancia de EC2 ($INSTANCE_ID) tiene la dirección IP pública: $PUBLIC_IP"

# Esperar hasta que la instancia esté en estado 'running' antes de conectarse por SSH
aws ec2 wait instance-status-ok --region $AWS_REGION --instance-ids $INSTANCE_ID

#Creamos Ip elastica
allocation=$(aws ec2 allocate-address --domain vpc)

readarray -t ip_address < <(aws ec2 allocate-address --domain vpc --query 'PublicIp' --output json)

#Asociar Ip elastica a Instancia Ec2
aws ec2 associate-address --instance-id "$INSTANCE_ID" --public-ip "${ip_address[0]}"

# Conectar por SSH a la instancia
echo "Conectándose por SSH a la instancia de EC2 ($INSTANCE_ID)..."
ssh -i C:/Users/KAARSTTHENN/PEM/$KEY_PAIR_NAME.pem ec2-user@$PUBLIC_IP

