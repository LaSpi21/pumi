#/bin/bash

#Este archivo asiste para borrar todas las acciones programadas en crontab o por numero de línea.

confirm=n
read -p "Indique que acciones borrar, ingrese T para borrar TODAS las acciones, un número para borrar la acción de la línea que corresponda a ese número o c para cancelar [t/n°/c]: " confirm_input

case $confirm_input in
  [tT]) confirm=true ;;
esac

case $confirm_input in
  [^tT0-9]) confirm=false ;;
esac

#en caso de haberse ingresado T/t se borran todas acciones programadas en crontab,
#en caso de ingresarse un numero se buscará borrar la entrada de numero de línea correspondiente

if [ "$confirm" = true ]; then
echo "Borrando todas las acciones programadas"
sudo crontab -r
exit
fi

if [ "$confirm" = false ]; then
echo "Cancelando operación"
exit
fi

confirm="$confirm_input"d
sudo crontab -l | grep -v '^#' | awk NF | sed "$confirm" | sudo crontab -









