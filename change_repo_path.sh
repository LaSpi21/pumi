#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

repo_path_file="$SCRIPT_DIR/Repo_path"
repo_path=""

echo Configurando repositorio de imagenes

read -e -p "Ingresa la nueva ruta al repositorio (ej. /media/user/repo/)" repo_path


sed -i "1s|.*|$repo_path|" "$repo_path_file"

ID_repo=$(sudo blkid -o value -s UUID $(\df --output=source "$repo_path"|tail -1))

sed -i "2s|.*|$ID_repo|" "$repo_path_file"



