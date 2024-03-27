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

#### 1 Configuración de acciones programadas:

- Aquí encontraremos opciones para realizar los cambios de imagen:
- 1-> 1 Realizar un cambio de imagén: Se le pedirá que seleccione una imagen a desplegar, si la misma no se encuentra agregada además se pedirá que indique si se trata de una partición o un disco. Esta acción puede realizarse de forma automatizada en todas las máquinas o encendiendo de forma manual las que se requieran modificar, esto es útil cuando solo algunas máquinas requieren cambios, se le preguntará cual de las dos opciones se prefiere. Luego el servidor se reiniciará para bootear Clonezilla, de aquí en más el proceso es automático, el servidor se reiniciará sólo luego de que pase el tiempo estipulado.
- 1 -> 2 Programar un cambio de imagen: esta función programa un cambio de imagen en todas las instancias que coincidan con el día, hora, minuto, día y mes especificados, considerando "*" como comodines. Igual que en el caso anterior, se le pedirá que seleccione una imagen. Esta función solo permite inicios automatizados, aunque si Wake-on-LAN no está habilitado en la imagen anterior de las computadoras, es posible que deban encenderse manualmente una vez que Clonezilla indique el inicio de Wake-on-LAN.
- 1 -> 3 Ver las acciones programadas: Imprime en pantalla las acciones programadas en formato crontab.
- 1 -> 4 Borrar acciones programadas: Permite borrar una o todas las acciones programadas vistas en el punto anterior.
- 1 -> 5 Cambiar el tiempo límite para el cambio de imagen: Modifica el tiempo que espera Clonezilla para reiniciar el servidor durante un cambio de imagen.
- 1 -> 6 Programar una hora de apagado general: Si se configura Pumi apagará todas las computadoras que maneja automaticamente todos los dias a la hora indicada.

#### 2 Configurar imágenes:

- Aquí encontraremos opciones relacionadas a las imagenes y su repositorio:
- 2 -> 1 Agregar imagen: Permite agregar una imagen para utilizar en el despliegue mediante Pumi, se preguntará si la misma es un disco completo o una partición.
- 2 -> 2 Cambiar dirección del repositorio de imágenes: Permite indicar una nueva ruta para que Pumi busque sus imagenes, esto además puede modificar el UUID del repositorio a fines de que clonezilla haga el montado correspondiente durante el despliegue.

#### 3 Configurar máquinas:

- Aquí podremos modificar las máquinas que Pumi tiene en su orbita:
- 3 -> 1 Agregar máquinas: Permite agregar una máquina ingresando sus datos o varias indicando un archivo con formato adecuado que contenga esta información (.csv con formato Mac,IP,Serie,user,,).
- 3 -> 2 Quitar máquina: Permite seleccionar una máquina para quitarla del dominio de Pumi.
- 3 -> 3 Recuperar máquina: Las máquinas quitadas pueden ser recuperadas mediante esta opción.
- 3 -> 4 Correr un script en las máquinas: permite enviar y ejecutar scriptsde shell en las máquinas bajo el dominio de Pumi.
- 3 -> 5 Realizar un registro de las máquinas: Permite hacer un registro manual simple de las máquinas, este tipo de registros se hace automáticamente luego de cada cambio de imagen.

#### 4 Apagar o encender máquinas:
- 4 Simplemente permite encender o apagar todas las maquinas en el dominio de Pumi.

  




- Seleccionar la opción 1 en el menú principal (Configurar acciones programadas).
- Luego, seleccionar nuevamente la opción 1 en el submenú (Programar un cambio de imagen).

### Limitaciones actuales:
- Las computadoras que intenten arrancar a través de la red dentro de la VLAN en el momento del cambio de imagen se someterán a la creación de imágenes sin validación por parte de PUMI.
- Las imágenes deben residir en el directorio raíz de la partición/disco/USB designado como repositorio de imágenes.
- Los cortes de energía o interrupciones de red durante los cambios de imagen requieren intervención manual para volver a desplegar imágenes. Se están explorando soluciones automatizadas para tales escenarios.
- El registro actualmente no contiene detalles más allá del nombre de la imagen y requiere una mayor elaboración para obtener una descripción más completa.
- Clonezilla reconoce cuando se termina de realizar un cambio de imagen pero no logré automatizar su respuestas para que se reinicie en este punto, de esto deriva la existencia del tiempo limite de reinicio.


