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
    echo "3. Agregar maquina/s"
    echo "4. Quitar maquina"
    echo "5. Recuperar maquina"
    echo "6. Encender o apagar maquinas"
    echo "7. Ver las acciones programadas"
    echo "8. Borrar acciones programadas"
    echo "9. Salir"
    
    read opcion
    
    case $opcion in
        1)
            echo "Programando un cambio de imagen"
            sudo bash "$SCRIPT_DIR"/schedule.sh
            ;;
        2)
            echo "Configurar imágenes"
            sudo bash "$SCRIPT_DIR"/manage_images.sh
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
            sudo bash "$SCRIPT_DIR"/view_crontab.sh
            ;;
        8)
            sudo bash "$SCRIPT_DIR"/erase_crontab.sh
            ;;
        9)
           echo "Saliendo.."
           break
           ;;
        *)
            echo "Opción no válida. Por favor, selecciona 1, 2, 3, 4 o 5."
            ;;
    esac
done    
    
