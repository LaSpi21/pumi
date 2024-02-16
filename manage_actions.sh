#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'



first_iteration=true

while true; do

    # Check if it's not the first iteration
    if [ "$first_iteration" != true ]; then
        echo "Presione cualquier tecla para continuar"
        read -n 1 -s -r -p ""
    fi

    # Set first_iteration to false after the first iteration
    first_iteration=false

    clear
    echo "Pumi. Configurar acciones programadas."
    echo "Selecciona una acción:"
    echo "1. Programar un cambio de imagen"
    echo "2. Ver las acciones programadas"
    echo "3. Borrar acciones programadas"
    echo "4. Cambiar el tiempo limite para el cambio de imagen"
    echo "4. Volver al menú principal"

    read opcion
    
    case $opcion in

        1)
            echo "Programando una nueva acción"
            sudo bash "$SCRIPT_DIR"/schedule.sh
            ;;

        2)
            sudo bash "$SCRIPT_DIR"/view_crontab.sh
            ;;
        3)
            sudo bash "$SCRIPT_DIR"/erase_crontab.sh
            ;;
        4)
            sudo bash "$SCRIPT_DIR"/change_timeout.sh
            ;;
        5)
           break
           ;;
        *)
            echo "Opción no válida. Por favor, selecciona 1, 2, 3 ó 4."
            ;;
    esac
done    
