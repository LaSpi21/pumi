#!/bin/bash

#Archivo que se encarga de la configuración de pumi desde cero

#Indica la ruta del archivo para ubicar de forma relativa el resto

OLD_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_DIR="$(dirname "$OLD_SCRIPT_DIR")/.pumi"
sudo mv "$OLD_SCRIPT_DIR"/  "$SCRIPT_DIR"


#Indica la ruta del archivo al archivo pumi para poder llamar al programa desde línea de comando
sudo sed -i "2i\DIR=$SCRIPT_DIR" "$SCRIPT_DIR"/pumi
sudo mv $SCRIPT_DIR/pumi /usr/local/bin
sudo chmod +x /usr/local/bin/pumi


# Define dependencias
dependencies=("crontab" "expect" "wakeonlan" "grub2" "ssh" "openssh-client" "ssmtp" "mpack" "iptables-persistent" "sshpass" "wget" "awk" "jq" "nmap")

# Instala dependencias en caso de no estar instaladas previamente
for dep in "${dependencies[@]}"; do
    if ! dpkg -s "$dep" &> /dev/null; then
        echo "Instalando $dep..."
        sudo apt-get install -y "$dep"
    else
        echo "$dep ya se encuentra instalada."
    fi
done

#Descarga clonezilla. Revisar a futuro si esta versión sigue teniendo soporte
wget -O "$SCRIPT_DIR"/clonezilla.iso https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.1.2-9/clonezilla-live-3.1.2-9-amd64.iso/download?use_mirror=sitsa

#Configura los puertos minimos para que el programa funcione dentro de la VLAN.
sudo ufw allow ssh
iptables -A INPUT -p tcp  --match multiport --dports 22,53,80,111,443,587,2049,8000 -j ACCEPT
iptables -A INPUT -p udp  --match multiport --dports 7,9,53,67,68,69,111,2049,4011 -j ACCEPT
#sudo UFW disable
sudo iptables-save -c > /etc/iptables/rules.v4

#Crea ssh keys en caso de que no existan 
sudo ssh-keygen -t rsa -f /root/.ssh/id_rsa -N "" <<<n

#Abre la configuracion de mail y repositorio
sudo bash $SCRIPT_DIR/configure_imaging.sh

# Define la entrada base de GRUB para clonezilla
entrada_grub="menuentry 'Clonezilla'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset locales= keyboard-layouts= ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_batch="no" vga=791 ip= net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO"
initrdefi (loop)/live/initrd.img
}"

echo "$entrada_grub" | sudo tee -a /etc/grub.d/40_custom > /dev/null
sudo update-grub
#Añade la informacion de los nodos para wakeonlan y comunicacion ssh
sudo bash $SCRIPT_DIR/ssh_add.sh

echo "Instalación completa, no olvides asegurarte que el tiempo limite de clonado es consecuente con las imagenes y la velocidad de red disponibles."
