#!/bin/bash

#Funcion que es llamada por install.sh para configurar la implementacion del envio de log por mail y la direccion del repositorio

RED='\033[0;31m'
NC='\033[0m'

mail=""
pass=""

echo Configurando el mail
read -p "Ingresa el mail de uso (ejemplo@algo.com): " mail
read -p "Ingresa la contraseña de aplicación (si no se tiene una, generarla): " pass

#Lineas a agregar al archivo /etc/ssmtp/ssmtp.conf para habilitar el mail
conf="UseSTARTTLS=YES
FromLineOverride=YES
root=admin@pumi.com
mailhub=smtp.gmail.com:587
AuthUser="$mail"
AuthPass="$pass""
#AuthUser=ulab309@gmail.com
#AuthPass=gmegydkshtjjtjry"

echo "$conf" | sudo tee -a /etc/ssmtp/ssmtp.conf > /dev/null


#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
repo_path_file="$SCRIPT_DIR/Repo_path"
repo_path=""


#Pide la ubicacion absoluta del repositorio
echo Configurando repositorio de imagenes
read -e -p "Ingresa la ruta al repositorio (ej. /media/user/repo/)" repo_path

read -p "Utiliza la red un servidor DHCP? [y/n]: " answer

# Convertir la respuesta a minúsculas para manejar diferentes entradas del usuario
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Verificar si la respuesta es 'y' o 'yes' para establecer dhcp en true, de lo contrario, en false
if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
    dhcp=true
else
    dhcp=false
fi

#Completa el archivo /pumi/Repo_path con las rutas e uuids del repositorio y de la carpeta /pumi/
echo "$repo_path" | sudo tee "$repo_path_file" > /dev/null

ID_repo=$(sudo blkid -o value -s UUID $(\df --output=source "$repo_path"|tail -1))
repo_mount_point=$(blkid -o device -l -t UUID="$ID_repo")
echo "$ID_repo" | sudo tee -a "$repo_path_file" > /dev/null

ID_pumi=$(sudo blkid -o value -s UUID $(\df --output=source "$SCRIPT_DIR"|tail -1))
pumi_mount_point=$(blkid -o device -l -t UUID="$ID_pumi")
echo "$ID_pumi" | sudo tee -a "$repo_path_file" > /dev/null

echo "$mail" | sudo tee -a "$repo_path_file" > /dev/null

#Agrega un tiempo limite por defecto de 45 minutos para finalizar el cambio de imagen.
echo "45" | sudo tee -a "$repo_path_file" > /dev/null

echo "$dhcp" | sudo tee -a "$repo_path_file" > /dev/null


echo "pumi configurado, el tiempo maximo por defecto para clonar imagenes es 45 minutos, puede cambiarlo desde pumi>Configurar acciones programadas"


