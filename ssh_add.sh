#!/bin/bash

#Remueve la/s maquina/s indicada/s a la orbita de Pumi para su manejo

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BLUE='\033[0;34m';
RED='\033[0;31m'
NC='\033[0m'

# Valores por defecto
batch=false
Serie=""
MAC=""
IP=""
user=""
Image=""
p=""

#echo -e "${BLUE}La/s maquina/s a agregar deberan estar encendidas al momento de agregarse.${NC}";

# Función para validar que la variable no esté vacía
validar_no_vacio() {
  local valor=$1
  if [[ -z "$valor" ]]; then
    echo "${RED}La variable no puede estar vacía${NC}."
    uso
  fi
}

# Analizar las opciones de la línea de comandos
while getopts ":m:i:s:u:I:p:w:f" opt; do
  case $opt in
    m) MAC="$OPTARG" ;;
    i) IP="$OPTARG" ;;
    s) Serie="$OPTARG" ;;
    u) user="$OPTARG" ;;
    I) Image="$OPTARG" ;;
    p) p="$OPTARG" ;;
    \?) echo -e "${RED}Opción inválida: -$OPTARG${NC}" >&2; uso ;;
    :) echo -e "${RED}La opción -$OPTARG requiere un argumento.${NC}" >&2; uso ;;
  esac
done

# Función para mostrar el uso del script
uso() {
  echo "Uso del script: $0  -m <MAC> -i <IP> -s <Serie> -u <user> -I <Image>"
  exit 1
}

#Función para tomar los datos a partir de un archivo .csv
batching() {
    local MAC=$1
    local IP=$2
    local Serie=$3
    local user=$4
    local Image=$5
    local p=$6

    #Agrega la información del archivo al log.csv y a new.csv, también crea ssh.csv con la información que necesita para automatizar la comunicacion mediante ssh con estas maquinas
    sudo echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/log.csv
    sudo echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/new.csv
    sudo  echo  "$MAC","$IP","$Serie","$user","$Image","$p" >> "$SCRIPT_DIR"/log/ssh.csv

}

# Indicar si se quiere hacer un scan de la red
read -p "Indica si se quiere hacer un scanneo de la red para obtener los datos (las computadoras deberan estar encendidas, la red debe ser cerrada) [y/n, default = n]:  " scan

# Indicar como se ingresarán los datos
read -p "Indica si agregar en modo batch (Se requiere un archivo .csv con formato Mac,IP,Serie,user,, [y/n, default = n]" batch

if [[ "$batch" == "y" ]]; then
  read -e -p "Ingresa la ruta del archivo .csv: " archivo_csv
  read -s -p "Indica la contraseña de las maquinas para automatizar la conexion por ssh: " p
  while IFS=, read -r MAC IP Serial user Image sign; do
     batching "$MAC" "$IP" "$Serial" "$user" "$Image" "$p"
  done < "$archivo_csv"

else
  echo "Iniciando en modo normal."
  read -p "Ingresa MAC: " MAC
  read -p "Ingresa IP: " IP
  read -p "Ingresa número de Serie: " Serie
  read -p "Ingresa usuario: " user
  read -p "Ingresa Imagen actual (opcional): " Image
  read -s -p "Indica la contraseña de la maquina para automatizar la conexion por ssh: " p
  # Validar que las variables no estén vacías
  validar_no_vacio "$Serie"
  validar_no_vacio "$MAC"
  validar_no_vacio "$user"
  validar_no_vacio "$IP"


  #Agrega la información del archivo al log.csv y a new.csv, también crea ssh.csv con la información que necesita para automatizar la comunicacion mediante ssh con estas maquinas
  sudo echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/log.csv
  sudo  echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/new.csv
  sudo  echo  "$MAC","$IP","$Serie","$user","$Image","$p" >> "$SCRIPT_DIR"/log/ssh.csv

fi

echo Se agregaron las maquinas indicadas #Indicar MACs de las imagenes

