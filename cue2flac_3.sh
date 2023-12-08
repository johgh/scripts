#!/bin/bash

# Función que comprueba si un paquete está instalado
package_installed() {
      dpkg -s "$1" &> /dev/null
  }

# Función que instala un paquete si no está instalado
install_package() {
      if ! package_installed "$1"; then
              echo "$1 no está instalado en el sistema."
                  read -p "¿Desea instalarlo ahora? (y/n): " choice
                      case "$choice" in
                                y|Y ) sudo apt-get -y install "$1" ;;
                                      n|N ) echo "Abortando..." ; exit 1 ;;
                                            * ) echo "Opción no válida. Abortando..." ; exit 1 ;;
                                                esac
                                                  fi
                                              }

                                          # Comprobamos si los programas necesarios están instalados
                                          install_package shntool
                                          install_package cuetools
                                          install_package pv

                                          # Comprobamos que se ha proporcionado un fichero .cue y un fichero .flac o .ape
                                          if [ $# -lt 2 ]; then
                                                echo "Uso: $0 archivo.cue archivo.flac|archivo.ape [-o directorio_de_salida]"
                                                  exit 1
                                          fi

                                          # Obtenemos el nombre del fichero .cue (sin extensión)
                                          cue_file=$(basename "$1" .cue)

                                          # Comprobamos si se ha proporcionado un directorio de salida
                                          if [ "$1" = "-o" ]; then
                                                # Creamos el directorio de salida si no existe
                                                  output_dir="$2"
                                                    mkdir -p "$output_dir"
                                                else
                                                      # Si no se ha proporcionado directorio de salida, las pistas .flac se generan en el mismo directorio que el .cue
                                                        output_dir=$(dirname "$1")
                                          fi

                                          # Generamos los puntos de corte a partir del fichero .cue y mostramos información de progreso
                                          cuebreakpoints "$cue_file.cue" | pv -l -s $(cuebreakpoints "$cue_file.cue" | wc -l) -N "Generando pistas" | shnsplit -o flac "$2" -d "$output_dir" -a track -n %02d - |

                                              # Añadimos los tags a cada pista generada y mostramos información de progreso
                                          cuetag "$cue_file.cue" "$output_dir"/*.flac | pv -l -s $(ls "$output_dir"/*.flac | wc -l) -N "Añadiendo metadatos" > /dev/null

                                          # Comprobamos si se ha proporcionado un directorio de salida para mostrar el mensaje correcto al usuario
                                          if [ "$1" = "-o" ]; then
                                                echo "Las pistas .flac se han generado correctamente en el directorio $output_dir/$cue_file."
                                            else
                                                  echo "Las pistas .flac se han generado correctamente en el directorio $output_dir."
                                          fi

                                          # Preguntamos al usuario si desea borrar el directorio de salida
                                          read -p "¿Desea borrar el directorio $output_dir? (y/n): " choice
                                          case "$choice" in
                                                y|Y ) rm -rf "$output_dir" ;;
                                                  n|N ) echo "Saliendo sin borrar el directorio $output_dir." ;;
                                                    * ) echo "Opción no

