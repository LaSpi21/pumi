#!/bin/bash

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Tome en cuenta al realizar su archivo script debe contener su shebang correpondiente"

#toma la dirección de los csvs que puede necesitar utilizar
log_csv="$SCRIPT_DIR/log/log.csv"

file=""

custom="n"
read -p "Utilizar un script personalizado de Pumi? [y/n]: " custom

case $custom in
  [yY]) custom=true ;;
esac

if [ "$custom" = true ]; then
        echo "Scripts disponibles"
        column_values=($(ls -d "$SCRIPT_DIR"/custom_scripts/* | xargs -I {} basename {} '.sh'))
        PS3="Elegí un script: "
        select file in "${column_values[@]}"; do
            if [[ -n $file ]]; then
                break
            else
                echo "Opcion invalida."
                exit
            fi
        done

        file="$SCRIPT_DIR/custom_scripts/$file.sh"

    argv=""

    
    read -p "Requiere este script un argumento? (un nombre de paquete, libreria, etc?) [y/n]: " argp

    case $argp in
      [yY]) argp=true ;;
    esac
    if [ "$argp" = true ]; then
      read -p "Ingrese el argumento: " argv
    fi

else
        read -e -p "Ingresa la ruta del script a implementar: " file

fi


read -p "Ingresa el usuario administrador de los nodos: " admin
read -s -p "Ingresa la contraseña de admin de los nodos: " p

remote_path=/home/"$admin"/Desktop/temp_script.sh

#funcion que se encarga de automatizar la comunicacion con los nodos
adding_ssh() {
    local MAC=$1
    local IP=$2
    local Serie=$3
    local user=$4

    sudo sshpass -p "$p" ssh-copy-id -o StrictHostKeyChecking=no "$admin"@"$IP"
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

#funcion que corre el script en los nodos.
run_script(){
    local MAC=$1
    local IP=$2
    local Serie=$3
    local user=$4

    sudo sshpass -p "$p" scp "$file" "$admin@$IP":"$remote_path"

    sudo sshpass -p '$p' ssh -tt "$admin@$IP" 'echo "'"$p"'" | sudo -S bash "'"$remote_path"'" "'"$argv"'"'

    sudo sshpass -p '$p' ssh -tt "$admin@$IP" 'echo "'"$p"'" | sudo -S rm "'"$remote_path"'"'

}

# Pregunta al usuario si necesita encender las computadoras
read -p "Se necesita encender las computadoras? (y/n): " response

# Despierta los nodos solo si la respuesta es 'y'
if [ "$response" = "y" ]; then
    while IFS=, read -r mac ip_address serial user; do
        wake "$mac" "$ip_address" "$serial" "$user" &
    done < "$log_csv"

    wait
fi

#automatiza la conexion ssh
while IFS=, read -r MAC IP Serial user Image; do
   adding_ssh "$MAC" "$IP" "$Serial" "$user" &
done < "$log_csv"

wait


#corre el script indicado
while IFS=, read -r mac IP serial user; do
   run_script "$MAC" "$IP" "$Serial" "$user" &
done < "$log_csv"

wait

echo "Scripts corridos"








