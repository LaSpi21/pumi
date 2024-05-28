#!/bin/bash

#Menu principal de pumi


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'

IFS= read -r -s -p 'Ingrese la contraseña de Pumi: ' pw
echo

sum=$(echo -n "$pw" | md5sum | cut -d ' ' -f 1)

hash=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '6p')

if [ "$sum" = "$hash" ]; then
        echo ""
else
        echo "contraseña incorrecta, cerrando Pumi"
        exit 1
fi

#Usa un menu simple utilizando opciones para ir ingresando a los sub menues
while true; do
    clear
    echo "Pumi. Menú principal."
    echo "Selecciona una acción:"
    echo "1. Configurar acciones programadas"
    echo "2. Configurar imagenes"
    echo "3. Configurar máquinas"
    echo "4. Encender o apagar maquinas"
    echo "5. Actualizar Pumi"
    echo "6. Salir"
    
    read opcion
    
    case $opcion in
        1)
            sudo bash "$SCRIPT_DIR"/manage_actions.sh
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
            sudo bash "$SCRIPT_DIR"/update_pumi.sh
            ;;
   
        6)
           echo "Saliendo.."
           break
           ;;
        *)
            echo "Opción no válida. Por favor, selecciona 1, 2, 3, 4, 5 ó 6."
            ;;
    esac
done    
    
