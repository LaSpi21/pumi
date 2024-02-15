#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

mail=""
pass=""

echo Configurando el mail
read -p "Ingresa el mail de uso (ejemplo@algo.com): " mail
read -p "Ingresa la contraseña de aplicación (si no se tiene una, generarla): " pass

conf="UseSTARTTLS=YES
FromLineOverride=YES
root=admin@pumi.com
mailhub=smtp.gmail.com:587
AuthUser="$mail"
AuthPass="$pass""
#AuthUser=ulab309@gmail.com
#AuthPass=gmegydkshtjjtjry"

echo "$conf" | sudo tee -a /etc/ssmtp/ssmtp.conf > /dev/null


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
repo_path_file="$SCRIPT_DIR/Repo_path"
repo_path=""
mail=""


echo Configurando repositorio de imagenes
read -e -p "Ingresa la ruta al repositorio (ej. /media/user/repo/)" repo_path

echo "$repo_path" | sudo tee "$repo_path_file" > /dev/null

ID_repo=$(sudo blkid -o value -s UUID $(\df --output=source "$repo_path"|tail -1))
repo_mount_point=$(blkid -o device -l -t UUID="$ID_repo")
echo "$ID_repo" | sudo tee -a "$repo_path_file" > /dev/null

ID_pumi=$(sudo blkid -o value -s UUID $(\df --output=source "$SCRIPT_DIR"|tail -1))
pumi_mount_point=$(blkid -o device -l -t UUID="$ID_pumi")
echo "$ID_pumi" | sudo tee -a "$repo_path_file" > /dev/null

echo "$mail" | sudo tee -a "$repo_path_file" > /dev/null

echo "45" | sudo tee -a "$repo_path_file" > /dev/null

echo pumi configurado
