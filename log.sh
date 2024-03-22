#!/bin/bash

#Archivo que se encarga de la comunicacion con los nodos y de enviar el log por mail

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#toma la dirección de los csvs que puede necesitar utilizar
log_csv="$SCRIPT_DIR/log/log.csv"
fail_csv="$SCRIPT_DIR/log/failed.csv"
historic="$SCRIPT_DIR/log/historic.csv"
new_csv="$SCRIPT_DIR/log/new.csv"
ssh_csv="$SCRIPT_DIR/log/ssh.csv"
temp="$SCRIPT_DIR/log/temp.csv"

#Toma el mail desde el archivo /pumi/Repo_path
mail=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '4p')

#toma día y mes para los casos donde se requiera volver a realizar la imagen
day=$(date +%d)
month=$(date +%m)

#instancia valores de opcionales
retry=false
onetimeonly=false


while getopts ":ro" opt; do
  case $opt in
    r) retry=true ;;
    o) onetimeonly=true ;;
esac
done

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
}

#funcion que se comunica y extrae la firma de los nodos (se puede trabajar para que extraiga mas información).
take_sign(){
    local mac=$1
    local ip_address=$2
    local serial=$3
    local user=$4
    
    txt_content="error"

    txt_content=$(sudo ssh -n "$user@$ip_address" "cat ./Desktop/.Signature")
    awk -F, -v pattern="$mac" -v signature="$txt_content" '$1 == pattern {$6=signature} 1' OFS="," "$log_csv" | sudo tee temp.csv && mv temp.csv "$log_csv"

    sudo ssh -n "$user@$ip_address" "sudo shutdown now"
}

#despierta los nodos
while IFS=, read -r mac ip_address serial user image sign; do
    wake "$mac" "$ip_address" "$serial" "$user" &
done < "$log_csv"

sleep 150

#automatiza la conexion ssh
while IFS=, read -r MAC IP Serial user Image p; do
   adding_ssh "$MAC" "$IP" "$Serial" "$user" "$Image" "$p" &
done < "$ssh_csv"

wait

sudo truncate -s 0 "$new_csv"

#toma las firmas de los nodos
while IFS=, read -r mac ip_address serial user image sign; do
    take_sign "$mac" "$ip_address" "$serial" "$user" &
done < "$log_csv"

wait

#borra todo las fallas obtenidas en el ultimo ciclo
sudo truncate -s 0 "$fail_csv"

#compara la imagen que deberían tener los nodos con la firma que tienen, en caso de no coincidir los incluye en el archivo failed.csv
while IFS=, read -r mac ip_address serial user image sign; do
     global_image="$image"
     if [ "$image" != "$sign" ]; then
         echo "$mac,$ip_address" | sudo tee -a "$fail_csv" > /dev/null
     fi
     done < "$log_csv"

#obsoleto, revisar si se puede borrar o si se necesita modificar otros archivos antes
if [ "$onetimeonly" = true ]; then
    sudo crontab -l | head -n -2 |sudo crontab -
fi

#en caso de tener el opcional "retry" vuelve a realizar imagen en aquellos nodos presenten en el archivo failed.csv
if [ "$retry" = true ]; then
    if [ -n "$(head -n 1 $fail_csv)" ]; then
 	sudo bash "$SCRIPT_DIR"/schedule.sh -d "$day" -M "$month" -u -f -i "$global_image";
  fi
fi

#Agrega la informacion de este ciclo al historico junto con la fecha
echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "$historic"
cat "$log_csv" >> "$historic"


fecha=$(date)

mpack -s "Este es un mensaje autogenerado con el log del día $fecha" "$SCRIPT_DIR"/log/log.csv "$mail" #mail implementation depende del puerto 587

