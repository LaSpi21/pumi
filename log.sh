#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_csv="$SCRIPT_DIR/log/log.csv"
fail_csv="$SCRIPT_DIR/log/failed.csv"
historic="$SCRIPT_DIR/log/historic.csv"
new_csv="$SCRIPT_DIR/log/new.csv"
temp="$SCRIPT_DIR/log/temp.csv"
mail=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '4p')

day=$(date +%d)
month=$(date +%m)

retry=false
onetimeonly=false


while getopts ":ro" opt; do
  case $opt in
    r) retry=true ;;
    o) onetimeonly=true ;;
esac
done

adding_ssh() {
    local MAC=$1
    local IP=$2
    local Serie=$3
    local user=$4
    local Image=$5
    local p=$6


    sudo sshpass -p "$p" ssh-copy-id -o StrictHostKeyChecking=no "$user"@"$IP"
}

wake() {
    local mac=$1
    local ip_address=$2
    local serial=$3
    local user=$4

    wakeonlan "$mac"

    sleep 100

}

take_sign(){
    txt_content="error"

    txt_content=$(sudo ssh -n "$user@$ip_address" "cat ./Desktop/Signature")
    awk -F, -v pattern="$mac" -v signature="$txt_content" '$1 == pattern {$6=signature} 1' OFS="," "$log_csv" | sudo tee temp.csv && mv temp.csv "$log_csv"

    sudo ssh -n "$user@$ip_address" "sudo shutdown now"
}



while IFS=, read -r mac ip_address serial user image sign; do
    wake "$mac" "$ip_address" "$serial" "$user" &
done < "$log_csv"

wait

while IFS=, read -r MAC IP Serial user Image p; do
   adding_ssh "$MAC" "$IP" "$Serial" "$user" "$Image" "$p" &
done < "$new_csv"

wait

sudo truncate -s 0 "$new_csv"

while IFS=, read -r mac ip_address serial user image sign; do
    take_sign "$mac" "$ip_address" "$serial" "$user"
done < "$log_csv"

sudo truncate -s 0 "$fail_csv"

while IFS=, read -r mac ip_address serial user image sign; do
     global_image="$image"
     if [ "$image" != "$sign" ]; then
         echo "$mac,$ip_address" | sudo tee -a "$fail_csv" > /dev/null
     fi
     done < "$log_csv"

if [ "$onetimeonly" = true ]; then
    sudo crontab -l | head -n -2 |sudo crontab -
fi

if [ "$retry" = true ]; then
    if [ -n "$(head -n 1 $fail_csv)" ]; then
 	sudo bash "$SCRIPT_DIR"/schedule.sh -d "$day" -M "$month" -u -f -i "$global_image";
fi
fi

echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "$historic"
cat "$log_csv" >> "$historic"


fecha=$(date)

mpack -s "Este es un mensaje autogenerado con el log del día $fecha" "$SCRIPT_DIR"/log/log.csv "$mail" #mail implementation depende del puerto 587

