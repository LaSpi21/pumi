# PUMI 🛠🐶

**Programed Unattended Machine Imaging**

PUMI es una herramienta que integra de manera transparente Clonezilla, SSH, Wake-on-LAN, crontab y otras utilidades para facilitar el programado de despliegue de imágenes completamente desatendido dentro de una red.


### Funciones:
- Configuración inicial y generación de imágenes de sistema automatizadas.
- Automatización de cambios de imagen por red.
- Programación de cambios de imagen.
- Programación de horario de apagado de las computadoras en red.
- Prendido y apagado general.
- Registro (Simple) de las computadoras en red.
- Enviar y ejecutar scripts en las máquinas en red.


### Requisitos previos:
- Configurar la red para asegurar que todas las máquinas estén dentro de la misma red (preferiblemente en una VLAN).
- Configurar las máquinas para que arranquen a través de la red utilizando el archivo bootx64.efi.
- Abrir los siguientes puertos:
  - TCP: 22, 53, 80, 111, 443, 587, 2049, 8000
  - UDP: 7, 9, 53, 67, 68, 69, 111, 2049, 4011
- Ajustar la configuración del BIOS en cada nodo:
  - Lan Option ROM: habilitar
  - Network Stack: habilitar
  - IPv4 PXE support: habilitar
  - IPv6 PXE support: deshabilitar
  - Erp Ready: deshabilitar
  - USB Standby on S4/S5: habilitar
  - UEFI: habilitar
  - Boot option #1: Network: UEFI
  - Boot option #2: DISK: ubuntu
  - Secure boot: deshabilitar
  - GO2BIOS: habilitar
  - MSI fast boot: deshabilitar
  - Fast boot: deshabilitar

### Creación de imágenes:
- Asegurar que SSH y Wake-on-LAN estén habilitados para todas las imágenes.
Descargar los archivos del repositorio pumi_node y ejecutar Node_configuration.sh (https://github.com/LaSpi21/pumi_node).
Recomendado: Configurar usuarios admin y no-admin.


- Crear la imagen replicando el estado del sistema deseado en una máquina (idealmente con un disco de igual o menor tamaño que las máquinas objetivo).

Correr SaveImage, seguir los pasos indicados.

### Dependencias:
- Clonezilla
- crontab
- expect
- wakeonlan
- grub2
- ssh
- openssh-client
- ssmtp
- mpack
- iptables-persistent
- sshpass
- wget
- awk
- nmap (opcional)

### Instalación:
1. Configurar la red para PUMI.
2. Configurar la configuración del BIOS en las computadoras objetivo según las instrucciones.
3. Opcionalmente, configurar una cuenta de Gmail para recibir notificaciones.
4. Montar el repositorio de imágenes.
5. Descargar PUMI y ejecutar el script install.sh para manejar las dependencias y la configuración de red:

sudo bash ~/pumi/install.sh
6. Seguir los pasos:
- Ingresar correo electrónico y contraseña generada para la configuración de ssmtp.
- Proporcionar una lista de MAC, IPs, nombres de usuario (en formato .csv) y contraseñas de imágenes para la automatización de la comunicación SSH.
- Especificar la dirección del repositorio de imágenes.
- Especificar una contraseña para Pumi

Una vez instalado, para inicar pumi:
- Abrir una terminal y ejecutar `$ pumi`.


### Usos:

El menú principal cuenta con 4 apartados:

- 1 Configuración de acciones programadas
  2 Configurar imágenes
  3 Configurar máquinas
  4 Encender o Apagar máquinas

## Configuración de acciones programadas:

- Aquí encontraremos opciones para realizar los cambios de imagen:
- 1->1 Realizar un cambio de imagén:

  




- Seleccionar la opción 1 en el menú principal (Configurar acciones programadas).
- Luego, seleccionar nuevamente la opción 1 en el submenú (Programar un cambio de imagen).

Recuerde, esto programa un cambio de imagen en todas las instancias que coincidan con el día, hora, minuto, día y mes especificados, considerando "*" como comodines. Si Wake-on-LAN no está habilitado en la imagen anterior de las computadoras, es posible que deban encenderse manualmente una vez que Clonezilla indique el inicio de Wake-on-LAN.

### Limitaciones actuales:
- Las computadoras que intenten arrancar a través de la red dentro de la VLAN en el momento del cambio de imagen se someterán a la creación de imágenes sin validación por parte de PUMI.
- Las imágenes deben residir en el directorio raíz de la partición/disco/USB designado como repositorio de imágenes.
- Los cortes de energía o interrupciones de red durante los cambios de imagen requieren intervención manual para volver a desplegar imágenes. Se están explorando soluciones automatizadas para tales escenarios.
- El registro actualmente no contiene detalles más allá del nombre de la imagen y requiere una mayor elaboración para obtener una descripción más completa.



