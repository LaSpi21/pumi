#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'



while true; do
    clear
    echo "Pumi. Menú principal."
    echo "Selecciona una acción:"
    echo "1. Programar un cambio de imagen"
    echo "2. Configurar imagenes"
    echo "3. Configurar máquinas"
    echo "4. Encender o apagar maquinas"
    echo "5. Ver las acciones programadas"
    echo "6. Borrar acciones programadas"
    echo "7. Salir"
    
    read opcion
    
    case $opcion in
        1)
            sudo bash "$SCRIPT_DIR"/schedule.sh
            ;;
            
        2)
            sudo bash "$SCRIPT_DIR"/manage_images.sh
            ;;
            
        3)
            sudo bash "$SCRIPT_DIR"/manage_machines.sh
            ;;

        4)
            sudo bash "$SCRIPT_DIR"/power.sh
            ;;
    
        5)
            sudo bash "$SCRIPT_DIR"/view_crontab.sh
            ;;
        6)
            sudo bash "$SCRIPT_DIR"/erase_crontab.sh
            ;;
        7)
           echo "Saliendo.."
           break
           ;;
        *)
            echo "Opción no válida. Por favor, selecciona 1, 2, 3, 4 o 5."
            ;;
    esac
done    
    
