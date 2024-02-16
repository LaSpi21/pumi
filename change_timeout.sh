#/bin/bash

#Cambia el tiempo limite que espera clonezilla para reiniciarse en el archivo /pumi/Repo_path

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

repo_path_file="$SCRIPT_DIR/Repo_path"
minutos=""

echo "Cambiando el tiempo limite del cambio de imagen."

#Funcion que valida que los minutos indicados sean un numero entero
validar_minuto() {
  local min=$1
  min=$(expr $min + 0)
  if [[ ! "$min" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Cantidad de minutos inválida. La cantidad debe ser un número entero.${NC}"
    exit 1
  fi
}

read -p "Ingresa el nuevo tiempo limite en minutos: " minutos

validar_minuto "$minutos"

#Modifica la linea de /pumi/Repo_path indicada
sed -i "5s|.*|$minutos|" "$repo_path_file"
