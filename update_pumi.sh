#!/bin/bash

#Actualiza Pumi a su versión de git main, no pisa los archivos con datos persistentes (Repo_path y log).

REPO_URL="https://github.com/LaSpi21/pumi.git"
TARGET_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMP_DIR=$(mktemp -d)
REPO_PATH_FILE="Repo_path"
LOG_DIR="log"

git clone $REPO_URL $TEMP_DIR

# Eliminar todos los contenidos en el directorio de destino excepto Repo_path y log
find $TARGET_DIR -mindepth 1 -maxdepth 1 ! -name $REPO_PATH_FILE ! -name $LOG_DIR -exec rm -rf {} +

# Eliminar todos los archivos no CSV en el directorio log
find $TARGET_DIR/$LOG_DIR -type f ! -name '*.csv' -exec rm -f {} +

# Sincronizar contenidos desde el directorio temporal al directorio de destino
# Excluir Repo_path y archivos *.csv dentro del directorio log
rsync -av --exclude=$REPO_PATH_FILE --exclude="$LOG_DIR/*.csv" $TEMP_DIR/ $TARGET_DIR/

# Limpia el directorio temporal
rm -rf $TEMP_DIR

echo "Actualización completa."

read -p "Se recomienda borrar las imagenes agregadas para asegurarse que las mismas son compatibles con la versión actual de Pumi, desea hacerlo ahora? [y/n]: " restartGrub

case $restartGrub in
  [yY]) restartGrub=true ;;
esac

if [ "$custom" = true ]; then
  sudo bash $TARGET_DIR/restartGrub.sh
fi


