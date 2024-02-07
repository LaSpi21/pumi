#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "$SCRIPT_DIR"
sudo sed -i "2i\DIR=$SCRIPT_DIR" "$SCRIPT_DIR"/pumi

sudo mv $SCRIPT_DIR/pumi /usr/local/bin
sudo chmod +x /usr/local/bin/pumi


# Define dependencies
dependencies=("crontab" "expect" "wakeonlan" "grub2" "ssh" "openssh-client" "ssmtp" "mpack" "iptables-persistent" "sshpass" "wget" "awk") #anymore?

# Check and install dependencies
for dep in "${dependencies[@]}"; do
    if ! dpkg -s "$dep" &> /dev/null; then
        echo "Installing $dep..."
        sudo apt-get install -y "$dep"
    else
        echo "$dep is already installed."
    fi
done

wget -O "$SCRIPT_DIR"/clonezilla.iso https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.1.2-9/clonezilla-live-3.1.2-9-amd64.iso/download?use_mirror=sitsa

#IPTABLES
sudo ufw allow ssh
iptables -A INPUT -p tcp  --match multiport --dports 22,53,80,111,443,587,2049,8000 -j ACCEPT
iptables -A INPUT -p udp  --match multiport --dports 7,9,53,67,68,69,111,2049,4011 -j ACCEPT
#sudo UFW disable
sudo iptables-save -c > /etc/iptables/rules.v4

sudo ssh-keygen -t rsa -f /root/.ssh/id_rsa -N "" <<<n
sudo bash $SCRIPT_DIR/configure_imaging.sh

# Definir la entrada base de GRUB para clonezilla
entrada_grub="menuentry 'Clonezilla'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset locales= keyboard-layouts= ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_batch="no" vga=791 ip= net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO"
initrdefi (loop)/live/initrd.img
}"

echo "$entrada_grub" | sudo tee -a /etc/grub.d/40_custom > /dev/null


sudo bash $SCRIPT_DIR/add_image.sh
sudo bash $SCRIPT_DIR/ssh_add.sh

echo Instalación completa
