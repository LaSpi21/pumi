#!/bin/bash

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#toma la dirección de los csvs que puede necesitar utilizar
log_csv="$SCRIPT_DIR/log/log.csv"
ssh_csv="$SCRIPT_DIR/log/ssh.csv"

file=""

read -e -p "Ingresa la ruta del script a implementar: " file

run=$(cat "$file")


#funcion que se encarga de automatizar la comunicacion con los nodos
adding_ssh() {
    local MAC=$1
    local IP=$2
    local Serie=$3
    local user=$4
    local Image=$5
    local p=$6


    sudo sshpass -p "$p" ssh-copy-id -o StrictHostKeyChecking=no "$user"@"$IP"
}

#funcion que se encarga de despertar a todos los nodos, ademas espera a que completen su booteo (con tiempo de sobra)
wake() {
    local mac=$1
    local ip_address=$2
    local serial=$3
    local user=$4

    wakeonlan "$mac"

    sleep 150

}

#funcion que se comunica y extrae la firma de los nodos (se puede trabajar para que extraiga mas información).
run_script(){
    local MAC=$1
    local IP=$2
    local Serie=$3
    local user=$4
    local Image=$5
    local p=$6
    
    sudo sshpass -p "$p" sudo ssh -n "$user@$ip_address" $run
}

# Pregunta al usuario si necesita encender las computadoras
read -p "Se necesita encender las computadoras? (y/n): " response

# Despierta los nodos solo si la respuesta es 'y'
if [ "$response" = "y" ]; then
    while IFS=, read -r mac ip_address serial user image sign; do
        wake "$mac" "$ip_address" "$serial" "$user" &
    done < "$log_csv"

    wait
fi

#automatiza la conexion ssh
while IFS=, read -r MAC IP Serial user Image p; do
   run_script "$MAC" "$IP" "$Serial" "$user" "$Image" "$p" &
done < "$ssh_csv"

wait


#corre el script indicado
while IFS=, read -r mac ip_address serial user image sign; do
   adding_ssh "$MAC" "$IP" "$Serial" "$user" "$Image" "$p" &
done < "$ssh_csv"

wait

echo "Scripts corridos"
