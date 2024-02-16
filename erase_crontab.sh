#/bin/bash
confirm=n
read -p "Indique que acciones borrar, ingrese T para borrar TODAS las acciones, un número para borrar la acción de la línea que corresponda a ese número o c para cancelar [t/n°/c]: " confirm_input

case $confirm_input in
  [tT]) confirm=true ;;
esac

case $confirm_input in
  [cCnN]) confirm=false ;;
esac



if [ "$confirm" = true ]; then
echo borrando todas las acciones programadas
sudo crontab -r
exit
fi

if [ "$confirm" = false ]; then
exit
fi

if [ $? = 0 ]
then
confirm="$confirm_input"d
sudo crontab -l | grep -v '^#' | awk NF | sed "$confirm" | sudo crontab -
fi








