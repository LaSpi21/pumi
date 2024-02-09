#!/bin/bash


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

batching() {
    local MAC=$1
    local IP=$2
    local Serie=$3
    local user=$4
    local Image=$5
    local p=$6

    sudo echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/log.csv
    sudo echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/new.csv
    sudo  echo  "$MAC","$IP","$Serie","$user","$Image","$p" >> "$SCRIPT_DIR"/log/ssh.csv

#    sudo sshpass -p "$p" ssh-copy-id -o StrictHostKeyChecking=no "$user"@"$IP"

#    sudo expect "$SCRIPT_DIR"/ssh_add.exp "$user" "$IP"

}


# Obtener entrada del usuario
read -p "Indica si agregar en modo batch (Se requiere un archivo .csv con formato Mac,IP,Serie,user,, [si/no, default = no]" batch

if [[ "$batch" == "si" ]]; then
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


  # Agregar las validaciones necesarias según tus requisitos

  # Añadir las variables al archivo CSV"
  sudo echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/log.csv
  sudo  echo  "$MAC","$IP","$Serie","$user","$Image", >> "$SCRIPT_DIR"/log/new.csv
  sudo  echo  "$MAC","$IP","$Serie","$user","$Image","$p" >> "$SCRIPT_DIR"/log/ssh.csv
#  sudo sshpass -p "$p" ssh-copy-id -o StrictHostKeyChecking=no "$user"@"$IP"

#  sudo expect "$SCRIPT_DIR"/ssh_add.exp "$user" "$IP"

fi

echo Se agregaron las maquinas indicadas #Indicar MACs de las imagenes
