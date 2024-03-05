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



while getopts ":i:" opt; do
  case ${opt} in
    i )
      nombre="$OPTARG"
     ;;
    \? )
      echo "Usage: $ [-i <image_name>"
      exit 1
      ;;
  esac
done

echo "$nombre"

# Se asegura que el disco/particion repositorio se encuentre montado
if ! findmnt -rno SOURCE,TARGET -S UUID="$uuid" | grep -q "^.*"; then
    # If not mounted, then attempt to mount the disk
    sudo mkdir -p "$repo" && sudo mount "$device_path" "$repo"
fi


# Escapa caracteres especiales
nombre_e=$(echo "$nombre" | sed 's/[^a-zA-Z0-9]/_/g')

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
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$repo_mount" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_prerun2=\\\"sudo mount UUID="$pumi_mount" /home/user/\\\" ocs_live_run=\\\"expect -f /home/user$SCRIPT_DIR/Restore.exp "$nombre_e" "$increment" "$num" ""\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO"
initrdefi (loop)/live/initrd.img
}"
            ;;

        2) entrada_grub="menuentry 'Restore $nombre_e'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$repo_mount" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_prerun2=\\\"sudo mount UUID="$pumi_mount" /home/user/\\\" ocs_live_run=\\\"expect -f /home/user$SCRIPT_DIR/Restore.exp "$nombre_e" "$increment" "$num" 5\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO"
initrdefi (loop)/live/initrd.img
}"
            ;;
        *)
        echo "Opción no válida. Por favor, selecciona 1 ó 2."
        exit
            ;;
esac


# Agregar la entrada de GRUB al archivo de configuración
echo "$entrada_grub" | sudo tee -a /etc/grub.d/40_custom > /dev/null

# Actualizar GRUB
sudo update-grub

