#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'



while true; do
    clear
    echo "Pumi. Configurar acciones programadas."
    echo "Selecciona una acción:"
    echo "1. Programar un cambio de imagen"
    echo "2. Ver las acciones programadas"
    echo "3. Borrar acciones programadas"
    echo "4. Volver al menú principal"

    read opcion
    
    case $opcion in

        1)
            sudo bash "$SCRIPT_DIR"/schedule.sh
            ;;

        2)
            sudo bash "$SCRIPT_DIR"/view_crontab.sh
            ;;
        3)
            sudo bash "$SCRIPT_DIR"/erase_crontab.sh
            ;;
        4)
           break
           ;;
        *)
            echo "Opción no válida. Por favor, selecciona 1, 2, 3 ó 4."
            ;;
    esac
done    
