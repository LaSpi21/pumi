#!/bin/bash

#Archivo para programar cambios de imagen en crontab

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Función para validar la hora
validar_hora() {
  local hora=$1
  hora=$(expr $hora + 0)
  if [[ ! "$hora" =~ ^[0-9]+$ || $hora -lt 0 || $hora -gt 23 ]]; then
    echo -e "${RED}Hora inválida. La hora debe ser un número entre 0 y 23.${NC}"
    uso
  fi
}
read -p "Ingresa la hora a la cual apagar (0-23): " user_hour
[[ -n "$user_hour" ]] && { validar_hora "$user_hour"; hour="$user_hour"; }

cron_line="0 $hour * * * bash $SCRIPT_DIR/Shutdown.sh"

temp_file=$(mktemp)

sudo crontab -l -u root > "$temp_file"

echo "$cron_line" >> "$temp_file"

sudo crontab -u root "$temp_file"

rm "$temp_file"

echo Se agregó "$cron_line"
