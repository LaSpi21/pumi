#/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

repo_path_file="$SCRIPT_DIR/Repo_path"
minutos=""

echo Configurando repositorio de imagenes

read -p "Ingresa el nuevo tiempo limite en minutos" minutos


sed -i "5s|.*|$minutos|" "$repo_path_file"
