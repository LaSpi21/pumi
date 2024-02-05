#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_csv="$SCRIPT_DIR/log/log.csv"
recycle_csv="$SCRIPT_DIR/log/recycle.csv"
new_csv="$SCRIPT_DIR/log/new.csv"

RED='\033[0;31m'
NC='\033[0m'

# Valores por defecto
opcion="c"
MAC=""
IP=""


# Función para validar que la variable no esté vacía
validar_no_vacio() {
  local valor=$1
  if [[ -z "$valor" ]]; then
    echo "${RED}La variable no puede estar vacía${NC}."
    uso
  fi
}


# Función para mostrar el uso del script
uso() {
  echo "Uso del script: $0  -o <opcion> "
  exit 1
}

# Analizar las opciones de la línea de comandos
while getopts ":o:" opt; do
  case $opt in
    o) opcion="$OPTARG" ;;
    \?) echo -e "${RED}Opción inválida: -$OPTARG${NC}" >&2; uso ;;
    :) echo -e "${RED}La opción -$OPTARG requiere un argumento.${NC}" >&2; uso ;;
  esac
done

read -p "Borrar mediante MAC o IP? [m/i/c (cancelar)]" opcion

if [[ "$opcion" == "m" ]]; then
	column_values=($(awk -F, '{print $1}' "$log_csv"))

	# Prompt user with autocompletion
	PS3="Select a value: "
	select MAC in "${column_values[@]}"; do
	    if [[ -n $MAC ]]; then
	        echo "Seleccionaste la MAC: $MAC"
		break
       else
	        echo "Opcion invalida."
	    fi
	done


    sudo awk -F, -v pattern=$MAC '$1 == pattern' OFS="," "$log_csv" >>  "$recycle_csv"
    sudo awk -F, -v pattern=$MAC '$1 != pattern' OFS="," "$log_csv" > temp.csv && sudo mv temp.csv "$log_csv"
    sudo awk -F, -v pattern=$MAC '$1 != pattern' OFS="," "$new_csv" > temp.csv && sudo mv temp.csv "$new_csv"


fi

if [[ "$opcion" == "i" ]]; then
        column_values=($(awk -F, '{print $2}' "$log_csv"))

        # Prompt user with autocompletion
        PS3="Select a value: "
        select IP in "${column_values[@]}"; do
            if [[ -n $IP ]]; then
                echo "Seleccionaste la IP: $IP"
		break
            else
                echo "Opcion invalida."
            fi
        done



    sudo awk -F, -v pattern=$IP '$2 == pattern' OFS="," "$log_csv" >> "$recycle_csv"
    sudo awk -F, -v pattern=$IP '$2 != pattern' OFS="," "$log_csv" > temp.csv && sudo mv temp.csv "$log_csv"
    sudo awk -F, -v pattern=$IP '$2 != pattern' OFS="," "$new_csv" > temp.csv && sudo mv temp.csv "$new_csv"

fi
