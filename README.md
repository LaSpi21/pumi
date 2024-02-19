# pumi
 Programed Unattended Machine Imaging





Requerimientos:

Configurar las máquinas para que sean compatibles

En cada nodo se debe configurar en BIOS estas opciones o equivalentes:

Lan Option ROM -> enable

Network Stack -> enable

IPv4 PXE support -> enable

IPv6 PXE support -> disable

Erp Ready -> disable

USB Stand by on S4/S5 -> enable

UEFI -> enable

Boot option #1 -> Network: UEFI

Boot option #2 -> DISK: ubuntu

Secure boot -> disable

GO2BIOS -> enable

MSI fast boot -> disable

Fast boot -> disable



Creación de la imagen

Toda imagen debe tener habilitada la comunicación por SSH

SSH:

Desde el nodo:

sudo apt install ethtool
sudo ethtool -s enp1s0 wol g
sudo systemctl enable –now -wol
sudo systemctl edit wol.service –full –force
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo ufw allow ssh
sudo visudo -> add tareas ALL=(ALL) NOPASSWD: /sbin/shutdown #needed to shutdown from ssh non-interactively


Para crear la imagen vamos a recrear el estado de sistema que queremos clonar en una máquina (cualquier máquina a los fines). Una vez hecho esto se bootea clonezilla y se sigue el siguiente instructivo, guardando la imagen en el disco. La imagen debe contener un archivo “Signature” en su /home/user/Desktop/ que contenga el nombre de la imagen, al seleccionar el nombre en clonezilla el mismo debe ser el contenido en Signature + “-img”

https://clonezilla.org/show-live-doc-content.php?topic=clonezilla-live/doc/01_Save_disk_image

Está operación puede ser larga, calculamos que no menos de 2 min por Gb utilizado.




Dependencias:

Clonezilla
crontab
expect 
wakeonlan 
grub2 
ssh 
openssh-client 
ssmtp 
mpack 
iptables-persistent 
sshpass 
wget 
awk
nmap?

Limitaciones actuales:

Toda computadora que traté de hacer boot por red dentro de la VLAN en el momento que el cambio de imagen comience tomará imagen sin hacer checks de que esa computadora corresponda con las MACs que maneja pumi.

Las imágenes deben estar en el root de la partición/disco/USB que se destinó como repositorio.

Dentro de una misma “aula” todas las imágenes que se usen deben tener el mismo nombre de usuario (esto es más fácil de solucionar si es necesario)

Cortes de luz… si se apaga el servidor las imágenes no se harán, si se corta la luz o la red durante el cambio de imagen no se efectuará un rollback por lo que habrá que volver a cambiar la imagen, estoy viendo formas de automatizar ante estos escenarios.. (esto puede ser complicado debido a que no tengo una forma consistente de encenderlas sin BMCs ni WoL, hay que probar para saber)

El log es bastante escueto aún y debería ser más descriptivo.



Modo de uso:

Configurar el BIOS en las computadoras del espacio a manejar.
Si se quiere utilizar una casilla de mails para recibir notificaciones crear un gmail y/o generar una clave de aplicaciones para gmail.
Configurar el BIOS para proporcionar energía a los periféricos USB en los estados S4/S5, y habilitar el arranque mediante UEFI en la máquina.
Tomar MACs e IPs del espacio que se quiera manejar utilizando nmap
$sudo nmap -sP xxx.xxx.xxx.0/xx | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print " => "$3;}' | sort
(esto se podrá automatizar facil?)
Abrir los puertos necesarios en la red, redirigir los pedidos de boot a la IP de la máquina a utilizar con el archivo bootx64.efi
Montar Repositorio de imágenes: Si se quiere utilizar el propio disco, crear una partición, caso contrario conectar el disco interno/externo que se utilizará como repositorio de imágenes (de alta lectura, baja escritura).
Descargar pumi desde nuestro repositorio (armar repo) o desde nuestro pendrive. Correr el archivo install.sh, este se encargará de resolver dependencias y configuración de red.

El programa pedirá:
-mail y clave generadas anteriormente, configurará el servicio ssmpt.
-una lista de MACs, IPs y nombre de usuario con formato .csv
-La dirección del repositorio de imágenes

Una vez instalado programar la primera imagen de las computadoras con $pumi opción 1.
Si las computadoras no tienen habilitado WoL en su imagen anterior deberán encender manualmente una vez que los wakeonlan comienzan en clonezilla. 
