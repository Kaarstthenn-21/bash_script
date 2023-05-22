# Interact with S3 by CLI

## Descripción

Este repositorio contiene ejemplos y scripts para interactuar con Amazon S3 utilizando la AWS CLI.

## Requisitos

- AWS CLI instalada y configurada con las credenciales adecuadas.

## Contenido

- [Menú de ayuda](#)
- [Listado de buckets](#)
- [Detalles de los objetos](#)
- [Crear bucket](#)
- [Listado de buckets - detalles](#)
- [Vaciar y eliminar buckets](#)
- [Vaciar objetos de bucket](#)
- [Sincronizar archivos con bucket](#)
## Menú de ayuda
El script `sh script.sh -h` permite obtener el menu, para poder visualizar las diferentes opciones del script.
```bash
sh script.sh -h o sh script.sh --help
output:
  ./script -h             | display this help message
  ./script list           | list buckets
  ./script listAll        | full list buckets
  ./script listObjects    | list objects of bucket
  ./script create         | create bucket
  ./script emptyDelete    | empty and delete bucket
  ./script empty          | only empty bucket
  ./script sync           | sync files, current directory

```
## Listado de buckets

El script `sh script.sh list` permite obtener la lista de buckets en tu cuenta de AWS.

```bash
$ sh script.sh list
output:
Listado de buckets
2023-04-28 14:33:12 $name_bucket1
...
2023-04-28 14:33:12 $name_bucketx
```

## Listado de buckets - Full detail
El script `sh script.sh listAll` permite obtener la lista de buckets en tu cuenta de AWS con mayores detalles.


```bash
$ sh script.sh listAll
output:
Listado de depositos buckets
Bucket: $backet_name1
Detalles:
Encriptación: AES256
Tamaño: 2 objetos
------------------------
Bucket: $backet_name2
Detalles:
Encriptación: AES256
Tamaño: 104 objetos

```

## Listado de objetos de un bucket
El script `sh script.sh listObjects` permite obtener los objetos de un bucket.

```bash
$ sh script.sh listObjects
output:
Introduzca nombre del bucket para listar sus objetos:
$bucket_name
Detalles de los objetos del bucket '$bucket_name':

Nombre: assets/css/style.css
Tamaño: 17706 bytes
Última Modificación: 2023-01-02T03:16:47+00:00
Clase de almacenamiento: STANDARD
Encriptación: AES256
-------------------------
```

## Crear bucket
El script `sh script.sh create` permite crear un bucket en la region pre configurada en `aws configure`
```bash
$ sh script.sh create
output:
Introduzca un nombre para su bucket S3:
$bucket_name
make_bucket: $bucket_name

```

## Eliminar bucket y objetos
El script `sh script.sh emptyDelete` permite eliminar los objetos del bucket especificado y proximamente el bucket.

```bash
$ sh script.sh emptyDelete
output:
Introduzca un nombre para su bucket S3:
$bucket_name
remove_bucket: $bucket_name

```
## Sincronizar archivos con bucket s3
El script `sh script.sh sync` permite sincronizar los archivos del archivo raiz con el bucket s3.

```bash
$ sh script.sh sync
output:
Introduzca nombre de bucket a sincronizar:
$bucket_name
upload: .\script.sh to s3://$bucket_name/file.extensionFile

```
## Eliminar objetos de bucket S3 en especifico
El script `sh script.sh empty` permite eliminar los objetos de un bucket en especifico.

```bash
$ sh script.sh empty
output:
Introduzca un nombre para su bucket S3:
$bucket_name
delete: s3://$bucket_name/fileObject.fileObjectExtension.


```

## 🔗 Links
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/alexander-ancco-escobar/)


