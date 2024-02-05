#/bin/bash
confirm=n
read -p "Confirmar que se quieren borrar todas las acciones programadas [y/n]: " confirm_input
case $confirm_input in
  [sSyY]) confirm=true ;;
esac

if [ "$confirm" = true ]; then
echo borrando todas las acciones programadas
sudo crontab -r
fi
