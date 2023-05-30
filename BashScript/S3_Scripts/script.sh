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
    TEST=$(aws s3 ls | grep "$NOMBRE$" | wc -l)
    if [ "$TEST" == "0" ]; then
        aws s3 sync ./ s3://$NOMBRE/templates/ --exclude ".git/*" --exclude "*.ini" --exclude ".sh" --delete || exit 1
    fi
    current_directory=$(dirname "$0")
    aws s3 sync "$current_directory" "s3://$NOMBRE"
}

create_s3() {
    read -p "Introduzca un nombre para su bucket S3:" bucket_name
    validate_bucket "$bucket_name"

    if [[ $? -eq 0 ]]; then
        echo "El bucket se ha creado correctamente."
    fi
}

empty() {
    echo 'Introduzca un nombre para su bucket S3:'
    read NOMBRE
    aws s3 rm s3://$NOMBRE --recursive
}

emptyAndDeleteBucket() {
    echo 'Introduzca un nombre para su bucket S3:'
    read NOMBRE
    aws s3 rm s3://$NOMBRE --recursive
    aws s3 rb s3://$NOMBRE
}

list() {
    echo 'Listado de buckets'
    aws s3 ls
}

fullList() {
    echo 'Listado de depositos buckets'
    buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

    if [ -n "$buckets" ]; then
        for bucket in $buckets; do
            echo "Bucket: $bucket"
            echo "Detalles:"

            bucket_encryption=$(aws s3api get-bucket-encryption --bucket "$bucket" --query 'ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text)
            if [ -n "$bucket_encryption" ]; then
                echo "Encriptación: $bucket_encryption"
            else
                echo "Encriptación: No se encontró encriptación configurada."
            fi

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

listObjects() {
    read -p "Introduzca nombre del bucket para listar sus objetos: " NOMBRE

    objects=$(aws s3api list-objects --bucket "$NOMBRE" --query 'Contents[].[Key, Size, LastModified, StorageClass, ServerSideEncryption]' --output text)

    if [ -n "$objects" ]; then
        echo "Detalles de los objetos del bucket '$NOMBRE':"
        echo

        while read -r key size last_modified storage_class encryption; do
            echo "Nombre: $key"
            echo "Tamaño: $size bytes"
            echo "Última Modificación: $last_modified"
            echo "Clase de almacenamiento: $storage_class"
            echo "Encriptación: $encryption"
            echo "-------------------------"
        done <<<"$objects"
    else
        echo "No se encontraron objetos en el bucket '$NOMBRE'."
    fi
}

function validate_bucket() {
    bucket_name=$1
    bucket_exists $bucket_name
    validate_bucket_name $bucket_name
    
    if [ ${#messages[@]} -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

function validate_bucket_name() {
    bucket_name=$1
    local message="Nombre no válido. Intenta con otro nombre."
    regex="^[a-z0-9.-]{3,63}$"
    if [[ ! $bucket_name =~ $regex ]]; then
        echo "$message"
    fi

}

function bucket_exists() {
    bucket_name=$1
    local message="El bucket que deseas crear, ya existe. Intenta con otro nombre."
    aws s3api head-bucket \
        --bucket "$bucket_name"
    # >/dev/null 2>&1

    if [[ ${?} -eq 0 ]]; then
        echo "$message"
    fi
}

menu() {
    while true; do
        clear
        echo "Menu interactivo:"
        echo "1. Listado de buckets"
        echo "2. Listado de buckets detallado"
        echo "3. Crear bucket"
        echo "4. Eliminar objetos de bucket"
        echo "5. Eliminar bucket completo"
        echo "6. Sincronizar archivos con bucket"
        echo "7. Salir"

        read -p "Seleccione una opción: " choice

        case $choice in
        1)
            list
            ;;
        2)
            fullList
            ;;
        3)
            create_s3
            ;;
        4)
            empty
            ;;
        5)
            emptyAndDeleteBucket
            ;;
        6)
            sync_files
            ;;
        7)
            echo "Gracias por usar menú interactivo CLI"
            echo "************************************************"
            echo "* Follow me in linkedin : Kaarstthenn Alexander*"
            echo "************************************************"
            exit 0
            ;;
        *)
            echo "Opción inválida. Por favor, seleccione una opción válida."
            ;;
        esac

        read -p "Presione Enter para continuar..."
    done
}

case ${1} in
"-h" | "--help") show_help ;;
"listAll") fullList ;;
"list") list ;;
"listObjects") listObjects ;;
"create") create_s3 ;;
"emptyDelete") emptyAndDeleteBucket ;;
"empty" | "--d") empty ;;
"sync" | "--s") sync_files ;;
"menu") menu ;;
esac
