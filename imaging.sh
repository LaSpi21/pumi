#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'

echo iniciando Imaging

echo "Selecciona una acción:"
echo "1. Programar un cambio de imagen"
echo "2. Agregar nueva imagen"
echo "3. Agregar maquina/s"
echo "4. Quitar maquina"
echo "5. Recuperar maquina"
echo "6. Encender o apagar maquinas"
echo "7. Cambiar dirección del repositorio"
echo "8. Ver las acciones programadas"
echo "9. Borrar todas las acciones programadas"

read opcion

case $opcion in
    1)
        echo "Programando un cambio de imagen"
        sudo bash "$SCRIPT_DIR"/schedule.sh
        ;;
    2)
        echo "Agregando nueva imagen"
        sudo bash "$SCRIPT_DIR"/add_image.sh
        ;;
    3)
        echo "Agreando maquina/s"
        sudo bash "$SCRIPT_DIR"/ssh_add.sh
        ;;
    4)
        echo "Quitando maquina"
        sudo bash "$SCRIPT_DIR"/ssh_remove.sh
        ;;
    5)
        echo "Recuperando maquina"
        sudo bash "$SCRIPT_DIR"/ssh_recover.sh
        ;;

    6)
        sudo bash "$SCRIPT_DIR"/power.sh
        ;;

    7)
        sudo bash "$SCRIPT_DIR"/change_repo_path.sh
        ;;
    8)
        sudo bash "$SCRIPT_DIR"/view_crontab.sh
        ;;
    9)
        sudo bash "$SCRIPT_DIR"/erase_crontab.sh
        ;;

    *)
        echo "Opción no válida. Por favor, selecciona 1, 2, 3, 4 o 5."
        ;;
esac
