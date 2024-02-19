#!/bin/bash

#Menú para configurar los nodos

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'



first_iteration=true

#
while true; do

    # en caso de no ser la primera iteración
    if [ "$first_iteration" != true ]; then
        echo "Presione cualquier tecla para continuar"
        read -n 1 -s -r -p ""
    fi

    # Despues de la primera iteración, indicar que esta ya sucedió
    first_iteration=false

    #Menu simple utilizando opciones

    clear
    echo "Pumi. Configurar máquinas."
    echo "Selecciona una acción:"
    echo "1. Agregar maquina/s"
    echo "2. Quitar maquina"
    echo "3. Recuperar maquina"
    echo "4. Volver al menú principal"
    
    read opcion
    
    case $opcion in
        1)
            echo "Agreando maquina/s"
            sudo bash "$SCRIPT_DIR"/ssh_add.sh
            ;;
        2)
            echo "Quitando maquina"
            sudo bash "$SCRIPT_DIR"/ssh_remove.sh
            ;;
        3)
            echo "Recuperando maquina"
            sudo bash "$SCRIPT_DIR"/ssh_recover.sh
            ;;
        4)
           break
           ;;
        *)
            echo "Opción no válida. Por favor, selecciona 1, 2, 3 ó 4."
            ;;
    esac
done    
    
