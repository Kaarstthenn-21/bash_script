source ./variables.sh

# **************************************************************************************
#                                     Configure Security group 22/80/443
# **************************************************************************************
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

# **************************************************************************************
#                                     Create Instance
# **************************************************************************************

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

# **************************************************************************************
#                                     Assign new Volume
# **************************************************************************************
# Obtener el ID del volumen EBS asociado a la instancia
VOLUME_ID=$(aws ec2 describe-volumes --filters "Name=attachment.instance-id,Values=$INSTANCE_ID" --query "Volumes[0].VolumeId" --output text)

# Detener la instancia EC2
aws ec2 stop-instances --instance-ids $INSTANCE_ID

# Esperar hasta que la instancia se detenga
echo "Esperando hasta que la instancia se detenga..."
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID

# Modificar el tamaño del volumen EBS
aws ec2 modify-volume --volume-id $VOLUME_ID --size $NEW_SIZE

# Modificar el tipo del volumen EBS
aws ec2 modify-volume --volume-id $VOLUME_ID --volume-type $NEW_VOLUME_TYPE

# Iniciar la instancia EC2 nuevamente
aws ec2 start-instances --instance-ids $INSTANCE_ID

# Esperar hasta que la instancia se inicie
echo "Esperando hasta que la instancia se inicie..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

echo "La configuración del volumen EBS ($VOLUME_ID) ha sido modificada exitosamente."

# **************************************************************************************
#                                     Assign elastic IP
# **************************************************************************************
# Obtener una dirección IP elástica disponible
AVAILABLE_IP=$(aws ec2 describe-addresses --filters "Name=instance-id,Values=NULL" --query 'Addresses[0].PublicIp' --output text)

# Comprobar si existe una dirección IP elástica disponible
AVAILABLE_IP=$(aws ec2 describe-addresses --query 'Addresses[?AssociationId==null]' --output text)
if [[ -z $AVAILABLE_IP ]]; then
  # Crear una nueva dirección IP elástica y asignarla a la instancia EC2
  echo "No se encontró una dirección IP elástica disponible. Creando una nueva dirección IP..."
  ALLOCATE_IP=$(aws ec2 allocate-address --domain vpc --query 'PublicIp' --output text)
  echo "La dirección IP $ALLOCATE_IP se ha creado correctamente."

  echo "Asignando la dirección IP $new_ip a la instancia $INSTANCE_ID..."
  aws ec2 associate-address --instance-id "$INSTANCE_ID" --public-ip "$ALLOCATE_IP"
  echo "La dirección IP $ALLOCATE_IP se ha asignado correctamente a la instancia $INSTANCE_ID."
  sleep 45
  # Conectar por SSH a la instancia+
  echo "Conectándose por SSH a la instancia de EC2 ($INSTANCE_ID)..."
  ssh -i C:/Users/KAARSTTHENN/PEM/$KEY_PAIR_NAME.pem ec2-user@$ALLOCATE_IP
else
  echo "Se encontró una dirección IP elástica disponible: $allocation"
  # Asignar la dirección IP disponible a la instancia EC2
  echo "Asignando la dirección IP $AVAILABLE_IP a la instancia $INSTANCE_ID..."
  aws ec2 associate-address --instance-id "$INSTANCE_ID" --public-ip "$AVAILABLE_IP"
  echo "La dirección IP $AVAILABLE_IP se ha asignado correctamente a la instancia $INSTANCE_ID."

  sleep 45
  # Conectar por SSH a la instancia+
  echo "Conectándose por SSH a la instancia de EC2 ($INSTANCE_ID)..."
  ssh -i C:/Users/KAARSTTHENN/PEM/$KEY_PAIR_NAME.pem ec2-user@$AVAILABLE_IP
fi