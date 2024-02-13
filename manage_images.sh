#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'

while true; do
    clear
    echo "Pumi. Configurar imágenes"
    echo "Selecciona una acción:"
    echo "1. Agregar nueva imagen"
    echo "2. Cambiar dirección del repositorio"
    echo "3. Volver al menú principal"

    read opcion
    
    case $opcion in
        1)
            echo "Agregando nueva imagen"
            sudo bash "$SCRIPT_DIR"/add_image.sh
            ;;
        2)
            echo "Cambiando la dirección del repositorio"
            sudo bash "$SCRIPT_DIR"/change_repo_path.sh
            ;;
        3)
            break
            ;;
        *)
            echo "Opción no válida. Por favor, selecciona 1, 2 ó 3."
            ;;
    esac
done
