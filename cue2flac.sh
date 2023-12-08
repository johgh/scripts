#!/bin/bash

# Paquetes necesarios
required_packages="shntool cuetools pv"

# Función para instalar paquetes faltantes
function install_packages() {
  read -p "¿Deseas instalar los paquetes faltantes? (y/n)" choice
  case "$choice" in
    y|Y ) sudo apt-get install $required_packages;;
    n|N ) echo "Abortando"; exit 1;;
    * ) echo "Opción inválida"; install_packages;;
  esac
}

# Función para eliminar el directorio de origen
function delete_directory() {
  read -p "¿Deseas eliminar el directorio de origen? (y/n)" choice
  case "$choice" in
    y|Y ) rm -r "$source_dir";;
    n|N ) echo "Saliendo sin borrar directorio";;
    * ) echo "Opción inválida"; delete_directory;;
  esac
}

# Verificar si los paquetes necesarios están instalados
missing_packages=()
for package in $required_packages; do
  if ! command -v "$package" &> /dev/null; then
    missing_packages+=("$package")
  fi
done

if [ ${#missing_packages[@]} -ne 0 ]; then
  echo "Los siguientes paquetes necesarios no están instalados: ${missing_packages[*]}"
  install_packages
fi

# Obtener los argumentos de entrada
while getopts ":o:" opt; do
  case ${opt} in
    o ) output_dir=${OPTARG};;
    \? ) echo "Opción inválida -$OPTARG"; exit 1;;
    : ) echo "Opción -$OPTARG requiere un argumento"; exit 1;;
  esac
done

shift $((OPTIND -1))

if [ -z "$1" ]
then
  echo "Uso: $0 [-o directorio_de_salida] archivo.cue"
  exit 1
fi

cue_file=$(basename "$1")
cue_name="${cue_file%.*}"

source_dir=$(dirname "$1")

# Verificar si el archivo .cue existe
if [ ! -f "$1" ]
then
  echo "El archivo .cue no existe"
  exit 1
fi

# Buscar archivo .flac/.ape con el mismo nombre que el archivo .cue
flac_file=$(find "$source_dir" -maxdepth 1 -type f -name "$cue_name.*" \( -name '*.flac' -o -name '*.ape' \) -print -quit)

# Verificar si el archivo .flac/.ape existe
if [ -z "$flac_file" ]
then
  echo "No se encontró un archivo .flac o .ape con el mismo nombre que el archivo .cue"
  exit 1
fi

flac_ext="${flac_file##*.}"
flac_name="${flac_file%.*}"

# Crear directorio de salida
mkdir -p "$output_dir/$cue_name"

# Extraer pistas
echo "Extrayendo pistas..."
cuebreakpoints "$cue_file" | shnsplit -o flac -d "$output_dir/$cue_name" -a "$flac_name" "$flac_file" | pv -t -e -b -s $(shnsplit -t %n "$flac_file" "$cue_file") -N "Creando pistas FLAC..."

# Agregar etiquetas a los archivos flac
echo "Agregando etiquetas a los archivos flac..."
cuetag "$cue_file" "$output_dir/$cue_name"/*.flac

# Preguntar si se desea borrar el directorio de origen
delete_directory

