#!/bin/bash

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#toma la ruta del archivo log
log_csv="$SCRIPT_DIR/log/log.csv"

funcion para apagar todos los nodos
shutdown(){
    echo apagando "$mac"
    sudo ssh -n "$user@$ip_address" "sudo shutdown now"
}

while IFS=, read -r mac ip_address serial user image sign; do
    shutdown "$mac" "$ip_address" "$serial" "$user" &
done < "$log_csv"

mail=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '4p')
mpack -s "Apagando coomputadoras" "$mail" 
