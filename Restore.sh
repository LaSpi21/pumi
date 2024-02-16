#!/bin/bash

#Este archivo se corre al momento de comenzar una imagen
#Esta encargado de programar un log para luego de realizar el cambio de imagen
#Luego reinicia el servidor a la entrada de grub correspondiente para el cambio inidicado


#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Toma el nombre de usuario por cuestiones de pathing
if [ "$EUID" -ne 0 ]; then
    # Script is not running as root, use the current username
    user_script=$(id -u -n)
else
    # Script is running as root (via sudo), use the original username
    user_script=$SUDO_USER
fi

#increment es la cantidad de tiempo que espera clonezilla para reiniciarse en minutos, se encuentra en el archivo /pumi/Repo_path
increment=$(($(cat "$SCRIPT_DIR/Repo_path"| sed -n '5p') + 30))

#toma la dirección de los csvs que puede necesitar utilizar
log_csv="$SCRIPT_DIR/log/log.csv"
macs_csv="$SCRIPT_DIR/log/Macs.csv"
new_csv="$SCRIPT_DIR/log/new.csv"
fail_csv="$SCRIPT_DIR/log/failed.csv"

#Variables para uso de opcionales
failed=false
new=false
retry=false
onetimeonly=false

#placeholder para el nombre de la imagen
image_name=""

#toma el momento en el cual programar el log
log_hour=$(date -d "+$increment minutes" "+%H")
log_min=$(date -d  "+$increment minutes" "+%M")
log_day=$(date -d  "+$increment minutes" "+%d")
log_month=$(date -d  "+$increment minutes" "+%m")


while getopts ":i:fnro" opt; do
  case ${opt} in
    i )
      image_name="$OPTARG"
     ;;
    f)
      failed=true
      ;;
    n)
      new=true
      ;;
    r)
      retry=true
      ;;
    o)
      onetimeonly=true
      ;;
    \? )
      echo "Usage: $ [-i <image_name>] [-f] [-n] [-r] [-o] "
      exit 1
      ;;
  esac
done

#linea base a agregar a crontab
cron_line="$log_min $log_hour $log_day $log_month * bash $SCRIPT_DIR/log.sh"

#pasa los opcionales recibidos a log.sh
if [ "$retry" = true ]; then
  cron_line="$cron_line -r"
fi

if [ "$onetimeonly" = true ]; then
  cron_line="$cron_line -o"
fi

cron_line="$cron_line && crontab -l | grep -v $SCRIPT_DIR/log.sh | crontab -"

temp_file=$(mktemp)

sudo crontab -l -u root > "$temp_file"

echo "$cron_line" >> "$temp_file"

sudo crontab -u root "$temp_file"

rm "$temp_file"

echo Se agregó "$cron_line"



#Cambia la imagen que figura para cada maquina en log.csv y borra las firmas
while IFS=, read -r mac ip_address serial user image sign; do
  awk -F, -v pattern="$mac" -v image="$image_name"  '$1 == pattern {$5=image;$6=""} 1' OFS="," "$log_csv" > temp.csv && mv temp.csv "$log_csv"
done < "$log_csv"

#copia las macs de las maquinas que recibiran imagen, solo las que se encuentren en macs_csv se usaran
if [ "$failed" = true ]; then
  sudo awk -F ',' '{print $1 "," $2}' "$fail_csv" | sudo tee "$macs_csv" > /dev/null

elif [ "$new" = true ]; then
 sudo awk -F ',' '{print $1 "," $2}' "$new_csv" | sudo tee "$macs_csv" > /dev/null
#sudo truncate -s 0 "$new_csv"

else
sudo awk -F ',' '{print $1 "," $2}' "$log_csv" | sudo tee "$macs_csv" > /dev/null
#sudo truncate -s 0 "$new_csv"

fi

#Indica la entrada de grub a utilizar y reinicia 
source /home/"$user_script"/.bashrc
sudo /usr/sbin/grub-reboot "Restore $image_name"
sleep 2
/sbin/reboot

