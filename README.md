# pumi
 Programed Unattended Machine Imaging


Este programa integra Clonezilla, ssh, wakeonlan, crontab y otras herramientas para realizar cambios de imagen programados completamente desatendidos dentro de una red.


Para utilizar pumi se requiere configurar la red de forma que todas las maquinas se encuentren bajo una misma (idealmente dentro de una VLAN) indicar que las maquinas deben bootear por red utilizando el archivo bootx64.efi y abrir los siguientes puertos:
TCP: 22,53,80,111,443,587,2049,8000
UDP: 7,9,53,67,68,69,111,2049,4011

Luego, en cada nodo se debe configurar en BIOS estas opciones o equivalentes:

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


Creacion de imagenes
Toda imagen debe tener habilitada la comunicación por SSH y wakeonlan

sudo apt install ethtool
sudo ethtool -s enp1s0 wol g
sudo systemctl enable –now -wol
sudo systemctl edit wol.service –full –force
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo ufw allow ssh
sudo visudo -> add tareas ALL=(ALL) NOPASSWD: /sbin/shutdown # Suficiente para permitir apagar los nodos de forma no interactiva.

Para crear la imagen vamos a recrear el estado de sistema que queremos clonar en una máquina (cualquier maquina con un disco de menor o, idealmente, el mismo tamaño que las maquinas destinatarias de la imagen). La imagen debe contener un archivo “Signature” en su /home/user/Desktop/ que contenga el nombre de la imagen, al seleccionar el nombre en clonezilla el mismo debe ser el contenido en Signature + “-img”
Una vez hecho esto se bootea mediante Clonezilla (desde usb) y se sigue el siguiente instructivo, guardando la imagen del disco. 

https://clonezilla.org/show-live-doc-content.php?topic=clonezilla-live/doc/01_Save_disk_image

Está operación puede ser larga dependiendo de la memoria disponible en la maquina en la que se realiza.




Dependencias que pumi instalará:

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

Modo de uso:

Configurar la red donde trabajará pumi.
Configurar el BIOS en las computadoras del espacio a manejar como se indicó anteriormente.
Si se quiere utilizar una casilla de mails para recibir notificaciones crear un gmail y/o generar una clave de aplicaciones para gmail.
Configurar el BIOS para proporcionar energía a los periféricos USB en los estados S4/S5, y habilitar el arranque mediante UEFI en el servidor.
Tomar MACs e IPs del espacio que se quiera manejar utilizando nmap u otra herramienta.
$sudo nmap -sP xxx.xxx.xxx.0/xx | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print " => "$3;}' | sort
(esto se podrá automatizar facil?)
Montar Repositorio de imágenes: Si se quiere utilizar el propio disco, crear una partición, caso contrario conectar el disco interno/externo que se utilizará como repositorio de imágenes (será de alta lectura, baja escritura).
Descargar pumi desde nuestro repositorio o desde nuestro pendrive. Correr el archivo install.sh, este se encargará de resolver dependencias y configuración de red: sudo bash ./pumi/install.sh luego de clonar el repositorio.

El programa pedirá:
-mail y clave generadas anteriormente, configurará el servicio ssmpt.
-una lista de MACs, IPs, nombre de usuario con formato .csv y la contraseña de las imagenes para automatizar la comunicación por ssh.
-La dirección del repositorio de imágenes.

Una vez instalado, para programar la primera imagen se abre el programa en terminal mediante $pumi y se selecciona la opcion 1 en el menú principal (Configurar acciones programadas) y luego nuevamente la opción 1 en el submenú (Programar un cambio de imagen).
Recordemos que esto programará un cambio de imagen en todas las instancias donde se cumplan la combinación de nombre de día, hora, minuto, día y mes considerando los caracteres "*" como comodines.
En caso en que las computadoras no tengan habilitado WoL en su imagen anterior es posible que se deban encender manualmente una vez clonezilla indique en pantalla que se inician los wakeonlan.



Limitaciones actuales:

Toda computadora que traté de hacer boot por red dentro de la VLAN en el momento que el cambio de imagen comience tomará imagen sin hacer checks de que esa computadora se encuentre en la orbita de pumi.

Las imágenes deben estar en el root de la partición/disco/USB que se destinó como repositorio.

Dentro de una misma “aula” todas las imágenes que se usen deben tener el mismo nombre de usuario y contraseña (esto es más fácil de solucionar si es necesario)

Cortes de luz… si se apaga el servidor las imágenes no se harán, si se corta la luz o la red durante el cambio de imagen no se efectuará un rollback por lo que habrá que volver a cambiar la imagen, estoy viendo formas de automatizar ante estos escenarios.. (esto puede ser complicado debido a que no tengo una forma consistente de encenderlas sin BMCs ni WoL, hay que probar para saber)

El log es bastante escueto aún y debería ser más descriptivo.
