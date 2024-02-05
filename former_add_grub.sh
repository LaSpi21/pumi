#!/bin/bash


RED='\033[0;31m'
NC='\033[0m'

uso() {
    echo "Uso: $0 <nombre>"
    exit 1
}

if [ "$#" -eq 0 ]; then
    echo Imagenes disponibles
    ls -d /media/pruebas/Image-Repo/*-img | xargs -I {} basename {} '-img'
    read -p "Ingresa el nombre de la imagen: " nombre
else
    nombre=$1
fi

# Escapar caracteres especiales
nombre_e=$(echo "$nombre" | sed 's/[^a-zA-Z0-9]/_/g')
directorio="/media/pruebas/Image-Repo/"  #Esto quiza en algun momento haya que revisar como hacerlo...
imageimg="${nombre_e}-img"

if [[ ! -d "$directorio$imageimg" ]]; then
    echo -e "${RED}Nombre de imagen inválido. No existe tal imagen en $directorio.${NC}"
    uso
fi



# Definir la entrada de GRUB
entrada_grub="menuentry 'Restore $nombre_e'{
set root=(hd1,gpt3)
linux /live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount /dev/sdb1 /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_prerun2=\\\"sudo mount /dev/sda2 /home/user/\\\" ocs_live_run=\\\"expect -f /home/user/Imaging/Restore.exp "$nombre_e"\\\" keyboard-layouts=\\\"en\\\" ocs_live_batch=\\\"yes\\\" locales=us_EN.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1
initrdefi /live/initrd.img
}"



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
