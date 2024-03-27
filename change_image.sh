#!/bin/bash

#Archivo para realizar un cambio de imagen

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#Indica la ruta del repositorio
repo=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '1p')


RED='\033[0;31m'
NC='\033[0m'

# Valores por defecto
image_name=""


#toma la uuid del repositorio y su direccion
uuid=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '2p')
device_path=$(blkid -U "$uuid" -s UUID -o device)


# Se asegura que el repositorio este montado
if ! findmnt -rno SOURCE,TARGET -S UUID="$uuid" | grep -q "^.*"; then
    # If not mounted, then attempt to mount the disk
    sudo mkdir -p "$repo" && sudo mount "$device_path" "$repo"
fi


# Función para mostrar el uso del script
uso() {
  echo "Uso: $0 [-H <hora>] [-d <día>] [-m <minuto>] [-M <mes>] [-w <día de la semana>] [-i <nombre_imagen>] | -u"
  echo "Modo interactivo: $0 -u"
  exit 1
}


echo Imagenes disponibles
column_values=($(ls -d "$repo"*-img | xargs -I {} basename {} '-img'))
PS3="Elegí una imagen: "
select image_name in "${column_values[@]}"; do
    if [[ -n image_name ]]; then
            images=($(awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg ))
            if [[ "${images[@]}" =~ .*Restore."$image_name".* ]]; then
                      echo "Seleccionaste la Imagen: $image_name"
             else
                      echo "La imagen no se encuentran añadida, añadiendo imagen.."
                      sudo bash "$SCRIPT_DIR"/add_image_auto.sh -i "$image_name"
            fi
            break
    else
            echo "Opcion invalida."
        fi
    done

read -p "Deseas encender las máquinas de forma manual? [y/n, default: n, las máquinas se encenderan automáticamente] " manual

case $manual in
    [yY]) manual=true ;;
  esac

elif [ "$manual" = true ]; then
        sudo bash "$SCRIPT_DIR/Restore.sh" -i "$image_name" -m
else
        sudo bash "$SCRIPT_DIR/Restore.sh" -i "$image_name"
fi


