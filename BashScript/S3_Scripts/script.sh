show_help() {
    echo "Usage: chmod +x script.sh"
    echo "  ./script -h             | display this help message"
    echo "  ./script list           | list buckets"
    echo "  ./script listAll        | full list buckets"
    echo "  ./script listObjects    | list objects of bucket"
    echo "  ./script create         | create bucket"
    echo "  ./script emptyDelete    | empty and delete bucket"
    echo "  ./script empty          | only empty bucket"
    echo "  ./script sync           | sync files, current directory"
}

sync_files() {
    echo 'Introduzca nombre de bucket a sincronizar:'
    read NOMBRE
    TEST=`aws s3 ls | grep "$NOMBRE\$" | wc -l`
    if [ "$TEST" == "0" ]; then
        aws s3 sync ./ s3://$NOMBRE/templates/ --exclude ".git/*" --exclude "*.ini" --exclude ".sh" --delete || exit 0
    fi
    current_directory=$(dirname "$0")
    # Ejecuta el comando para sincronizar los archivos
    aws s3 sync "$current_directory" "s3://$NOMBRE"
}

createS3() {
    echo 'Introduzca un nombre para su bucket S3:'
    read NOMBRE
    TEST=`aws s3 ls | grep "$NOMBRE\$" | wc -l`
    if [ "$TEST" == "0" ]; then
        aws s3 mb s3://$NOMBRE || exit 0
    fi
}

empty(){
    echo 'Introduzca un nombre para su bucket S3:'
    read NOMBRE
    aws s3 rm s3://$NOMBRE --recursive
}
emptyAndDeleteBucket(){
    echo 'Introduzca un nombre para su bucket S3:'
    read NOMBRE
    aws s3 rm s3://$NOMBRE --recursive
    aws s3 rb s3://$NOMBRE
}

list(){
    echo 'Listado de buckets'
    aws s3 ls
}

fullList(){
    echo 'Listado de depositos buckets'
    # Ejecuta el comando para listar los buckets de AWS
    buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)
    
    # Comprueba si hay buckets y muestra los detalles
    if [ -n "$buckets" ]; then
        for bucket in $buckets; do
            echo "Bucket: $bucket"
            echo "Detalles:"
            
            # Obtén los detalles del bucket
            bucket_encryption=$(aws s3api get-bucket-encryption --bucket "$bucket" --query 'ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text)
            if [ -n "$bucket_encryption" ]; then
                echo "Encriptación: $bucket_encryption"
            else
                echo "Encriptación: No se encontró encriptación configurada."
            fi
            
            # Obtén el tamaño del bucket
            bucket_size=$(aws s3api list-objects --bucket "$bucket" --query 'length(Contents[])' --output text 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$bucket_size" ]; then
                echo "Tamaño: $bucket_size objetos"
            else
                echo "Tamaño: No contiene objetos"
            fi
            
            
            echo "------------------------"
        done
    else
        echo "No se encontraron buckets de AWS."
    fi
}

listObjects(){
    echo 'Introduzca nombre del bucket para listar sus objetos:'
    read NOMBRE
    
    # Ejecuta el comando para listar los objetos del bucket y obtener detalles
    objects=$(aws s3api list-objects --bucket "$NOMBRE" --query 'Contents[].[Key, Size, LastModified, StorageClass, ServerSideEncryption]' --output text)

    # Comprueba si hay objetos y muestra los detalles
    if [ -n "$objects" ]; then
    echo "Detalles de los objetos del bucket '$NOMBRE':"
    echo

    # Itera sobre los objetos y muestra los detalles
    while read -r key size last_modified storage_class encryption; do
        echo "Nombre: $key"
        echo "Tamaño: $size bytes"
        echo "Última Modificación: $last_modified"
        echo "Clase de almacenamiento: $storage_class"
        echo "Encriptación: $encryption"
        echo "-------------------------"
    done <<< "$objects"
    else
    echo "No se encontraron objetos en el bucket '$NOMBRE'."
    fi
}

case ${1} in
    "-h" | "--help" ) show_help; ;;
    "listAll") fullList; ;;
    "list") list; ;;
    "listObjects") listObjects; ;;
    "create") createS3;  ;;
    "emptyDelete") emptyAndDeleteBucket; ;;
    "empty" | "--d" ) empty; ;;
    "sync" | "--s" ) sync_files; ;;
esac
