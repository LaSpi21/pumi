#!/bin/bash

#Agrega una entrada de grub para una nueva imagen

RED='\033[0;31m'
NC='\033[0m'

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#Toma la infromacion del repositorio y de pumi (direccion, uuid de la particion) y otras variables del archivo /pumi/Repo_path
repo=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '1p')
repo_mount=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '2p')
pumi_mount=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '3p')
increment=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '5p')
num=$(wc -l < "$SCRIPT_DIR"/log/log.csv)
uuid=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '2p')
device_path=$(blkid -U "$uuid" -s UUID -o device)


# Se asegura que el disco/particion repositorio se encuentre montado
if ! findmnt -rno SOURCE,TARGET -S UUID="$uuid" | grep -q "^.*"; then
    # If not mounted, then attempt to mount the disk
    sudo mkdir -p "$repo" && sudo mount "$device_path" "$repo"
fi

uso() {
    echo "Uso: $0 <nombre>"
    exit 1
}

if [ "$#" -eq 0 ]; then
    echo Imagenes disponibles
    column_values=($(ls -d "$repo"*-img | xargs -I {} basename {} '-img'))
    # Permite seleccionar la imagen de una lista, las imagenes deben cumplir con que su nombre sea *-img
    PS3="Select a value: "
    select nombre in "${column_values[@]}"; do
        if [[ -n $nombre ]]; then
                echo "Seleccionaste la Imagen: $nombre"
                break
        else
                echo "Opcion invalida."
            fi
        done
else
    nombre=$1
fi



# Escapa caracteres especiales
nombre_e=$(echo "$nombre" | sed 's/[^a-zA-Z0-9]/_/g')
imageimg="${nombre_e}-img"

if [[ ! -d "$repo$imageimg" ]]; then
    echo -e "${RED}Nombre de imagen inválido. No existe tal imagen en $repo.${NC}"
    uso
fi




echo "Es la imagen un disco o una partición?"
echo "1. Disco"
echo "2. Partición"
read opcion

#Definir la entrada de GRUB

case $opcion in
        1) entrada_grub="menuentry 'Restore $nombre_e'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$repo_mount" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_prerun2=\\\"sudo mount UUID="$pumi_mount" /home/user/\\\" ocs_live_run=\\\"expect -f /home/user$SCRIPT_DIR/Restore.exp "$nombre_e" "$increment" "$num"\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO"
initrdefi (loop)/live/initrd.img
}"
            ;;
        2)
        json=$(lsblk -J)

# Extraer los nombres y tamaños de los discos hijos
children=$(echo "$json" | jq -r '.blockdevices[] | select(has("children")) | .children[] | "\(.name) (\(.size))"')

# Limpiar el array de discos hijos
unset children_array

# Almacenar los discos hijos en un array
declare -a children_array

# Recorrer la cadena de discos hijos y poblar el array con el nombre y el tamaño combinados
while IFS= read -r line; do
    children_array+=("$line")
done <<< "$children"

# Mostrar opciones
echo "Selecciona un disco destino:"
for ((i=0; i<${#children_array[@]}; i++)); do
    echo "$(($i + 1)) ${children_array[$i]}"
done

# Solicitar al usuario que seleccione un hijo
read -p "Ingresa el número del disco destino entre las opciones: " choice
if [[ $choice =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#children_array[@]})); then
    selected_option="${children_array[$(($choice - 1))]}"
    echo "Seleccionaste: $selected_option"
else
    echo "Opción inválida. Por favor ingresa un número entre 1 y ${#children_array[@]}."
fi
disk=$(echo "$selected_option" | cut -d' ' -f1)

        entrada_grub="menuentry 'Restore $nombre_e'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$repo_mount" /mnt\\\" ocs_prerun1=\\\"mount --bind /m>
initrdefi (loop)/live/initrd.img
}"
            ;;

        *)
        echo "Opción no válida. Por favor, selecciona 1 ó 2."
        exit
            ;;
esac


confirm="no"
read -p "Estas seguro de agregar $nombre_e como una imagen?[y/n, default = no]" confirm
if [ "$confirm" = y ]; then
  echo agregando "$nombre_e"

  # Agregar la entrada de GRUB al archivo de configuración
  echo "$entrada_grub" | sudo tee -a /etc/grub.d/40_custom > /dev/null

  # Actualizar GRUB
  sudo update-grub
else
echo Cancelando..
fi
