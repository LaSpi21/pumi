
#!/bin/bash


RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
repo=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '1p')
#repo_mount=$(blkid -o device -l -t UUID=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '2p'))
#pumi_mount=$(blkid -o device -l -t UUID=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '3p'))

repo_mount=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '2p')
pumi_mount=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '3p')

uuid=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '2p')
device_path=$(blkid -U "$uuid" -s UUID -o device)
# Check if the disk is already mounted
if ! findmnt -rno SOURCE,TARGET -S UUID="$uuid" | grep -q "^.*"; then
    # If not mounted, then attempt to mount the disk
    sudo mkdir -p "$repo" && sudo mount "$device_path" "$repo"
fi


# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    # Script is not running as root, use the current username
    user=$(id -u -n)
else
    # Script is running as root (via sudo), use the original username
    user=$SUDO_USER
fi



uso() {
    echo "Uso: $0 <nombre>"
    exit 1
}

if [ "$#" -eq 0 ]; then
    echo Imagenes disponibles
    column_values=($(ls -d "$repo"*-img | xargs -I {} basename {} '-img'))
    # Prompt user with autocompletion
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

# Escapar caracteres especiales
nombre_e=$(echo "$nombre" | sed 's/[^a-zA-Z0-9]/_/g')
imageimg="${nombre_e}-img"

if [[ ! -d "$repo$imageimg" ]]; then
    echo -e "${RED}Nombre de imagen inválido. No existe tal imagen en $repo.${NC}"
    uso
fi



# Definir la entrada de GRUB
#entrada_grub="menuentry 'Restore $nombre_e'{
#ISO="$SCRIPT_DIR/clonezilla.iso"
#search --set -f "\$ISO"
#loopback loop "\$ISO"
#linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset locales= keyboard-layouts= ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_batch="no" vga=791 ip= net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO"
#initrd (loop)/live/initrd.img
#}"

entrada_grub="menuentry 'Restore $nombre_e'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$repo_mount" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_prerun2=\\\"sudo mount UUID="$pumi_mount" /home/user/\\\" ocs_live_run=\\\"expect -f /home/user$SCRIPT_DIR/Restore.exp "$nombre_e"\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO"
initrdefi (loop)/live/initrd.img
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
