#!/bin/bash


#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#toma la ruta del archivo log
log_csv="$SCRIPT_DIR/log/log.csv"

#instacia el valor de power_type
power_type="c"

#pide si se requieren encender o apagar las computadoras
read -p "Encender o apagar computadoras? [e/a]: " power_type

#funcion para despertar a todos los nodos
wake() {
#    local mac=$1
#    local ip_address=$2
#    local serial=$3
#    local user=$4
    echo encendiendo "$mac"
    wakeonlan "$mac"
}

#funcion para apagar todos los nodos
shutdown(){
    echo apagando "$mac"
    sudo ssh -n "$user@$ip_address" "sudo shutdown now"

}


#Apagar o encender dependiendo del valor ingresado para power_type
if [[ "$power_type" == "e" ]]; then
	while IFS=, read -r mac ip_address serial user image sign; do
	    wake "$mac" "$ip_address" "$serial" "$user" &
	done < "$log_csv"
wait
elif [[ "$power_type" == "a" ]]; then
        while IFS=, read -r mac ip_address serial user image sign; do
            shutdown "$mac" "$ip_address" "$serial" "$user" &
        done < "$log_csv"
wait

fi



#como esta accion esta fuera de todo submenú, se añade este separador
echo "Presione cualquier tecla para continuar"
read -n 1 -s -r -p ""

