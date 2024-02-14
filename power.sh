#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_csv="$SCRIPT_DIR/log/log.csv"

power_type="c"

read -p "Encender o apagar computadoras? [e/a]: " power_type


wake() {
#    local mac=$1
#    local ip_address=$2
#    local serial=$3
#    local user=$4
    echo encendiendo "$mac"
    wakeonlan "$mac"
}

shutdown(){
    echo apagando "$mac"
    sudo ssh -n "$user@$ip_address" "sudo shutdown now"

}



if [[ "$power_type" == "e" ]]; then
	while IFS=, read -r mac ip_address serial user image sign; do
	    wake "$mac" "$ip_address" "$serial" "$user" &
	done < "$log_csv"
elif [[ "$power_type" == "a" ]]; then
        while IFS=, read -r mac ip_address serial user image sign; do
            shutdown "$mac" "$ip_address" "$serial" "$user" &
        done < "$log_csv"


fi

echo "Presione cualquier tecla para continuar"
read -n 1 -s -r -p ""

