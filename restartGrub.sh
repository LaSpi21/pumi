#!/bin/bash

NEW_CONTENT="#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
menuentry 'Clonezilla'{
ISO=/clonezilla.iso
search --set -f \$ISO
loopback loop \$ISO
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset locales= keyboard-layouts= ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no vga=791 ip= net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso=\$ISO
initrdefi (loop)/live/initrd.img
}
"

echo "$NEW_CONTENT" > /etc/grub.d/40_custom

sudo update-grub

#como esta accion esta fuera de todo submenú, se añade este separador
echo "Presione cualquier tecla para continuar"
read -n 1 -s -r -p ""














