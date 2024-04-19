#!/bin/bash

#Archivo para programar cambios de imagen en crontab

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#Indica la ruta del repositorio
repo=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '1p')


RED='\033[0;31m'
NC='\033[0m'

# Valores por defecto
day="*"
current_time=$(date +"%H:%M")
month="*"
future_time=$(date -d "5 minutes" +"%H:%M")
IFS=':' read -r current_hour current_minute <<< "$current_time"
IFS=':' read -r future_hour future_minute <<< "$future_time"
hour="$future_hour"
min="$future_minute"
weekday="*"
image_name=""
repair_mode=false
modo_interactivo=true
retry=false
onetimeonly=false
increment=$(($(cat "$SCRIPT_DIR/Repo_path"| sed -n '5p') + 30))


#toma la uuid del repositorio y su direccion
uuid=$(cat "$SCRIPT_DIR/Repo_path"| sed -n '2p')
device_path=$(blkid -U "$uuid" -s UUID -o device)


# Se asegura que el repositorio este montado
if ! findmnt -rno SOURCE,TARGET -S UUID="$uuid" | grep -q "^.*"; then
    # If not mounted, then attempt to mount the disk
    sudo mkdir -p "$repo" && sudo mount "$device_path" "$repo"
fi


# Función para mostrar el uso del script
uso() {
  echo "Uso: $0 [-H <hora>] [-d <día>] [-m <minuto>] [-M <mes>] [-w <día de la semana>] [-i <nombre_imagen>] | -u"
  echo "Modo interactivo: $0 -u"
  exit 1
}

# Función para validar el día
validar_dia() {
  local dia=$1
  dia=$(expr $dia + 0)
  if [[ ! "$dia" =~ ^[0-9]+$ || $dia -lt 1 || $dia -gt 31 ]]; then
    echo -e "${RED}Día inválido. El día debe ser un número entre 1 y 31.${NC}"
    uso
  fi
}

# Función para validar el mes
validar_mes() {
  local mes=$1
  mes=$(expr $mes + 0)
  if [[ ! "$mes" =~ ^[0-9]+$ || $mes -lt 1 || $mes -gt 12 ]]; then
    echo -e "${RED}Mes inválido. El mes debe ser un número entre 1 y 12.${NC}"
    uso
  fi
}


# Función para validar la hora
validar_hora() {
  local hora=$1
  hora=$(expr $hora + 0)
  if [[ ! "$hora" =~ ^[0-9]+$ || $hora -lt 0 || $hora -gt 23 ]]; then
    echo -e "${RED}Hora inválida. La hora debe ser un número entre 0 y 23.${NC}"
    uso
  fi
}

# Función para validar el minuto
validar_minuto() {
  local min=$1
  min=$(expr $min + 0)
  if [[ ! "$min" =~ ^[0-9]+$ || $min -lt 0 || $min -gt 59 ]]; then
    echo -e "${RED}Minuto inválido. El minuto debe ser un número entre 0 y 59.${NC}"
    uso
  fi
}

# Función para validar el día de la semana
validar_dia_semana() {
  local dia_semana=$1
  if [[ ! "$dia_semana" =~ ^(Mon|Tue|Wed|Thu|Fri|Sat|Sun|\*)$ ]]; then
    echo -e "${RED}Día de la semana inválido. Las opciones válidas son 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun' o '*'.${NC}"
    uso
  fi
}

# Función para validar el nombre de la imagen, obsoleto?
validar_nombre_imagen() {
  local nombre_imagen=$1
  local imageimg="${nombre_imagen}-img"
  if [[ ! -d "$repo$imageimg" ]]; then
    echo -e "${RED}Nombre de imagen inválido. Debe ser un nombre de directorio en $repo.${NC}"
    uso
  fi
}



# Analizar las opciones de la línea de comandos
while getopts ":H:d:m:M:w:i:ufor" opt; do
  case $opt in
    H) validar_hora "$OPTARG"; hour="$OPTARG" ;;
    d) validar_dia "$OPTARG"; day="$OPTARG" ;;
    m) validar_minuto "$OPTARG"; min="$OPTARG" ;;
    M) validar_mes "$OPTARG"; month="$OPTARG" ;;
    w) validar_dia_semana "$OPTARG"; weekday="$OPTARG" ;;
    i) image_name="$OPTARG" ;;
    i) validar_nombre_imagen "$OPTARG"; image_name="$OPTARG" ;;

    u) modo_interactivo=false # modo interactivo
       ;;
    f) repair_mode=true # modo reparador
       ;;
    r) retry=true ;;
    o) onetimeonly=true ;;
    \?) echo -e "${RED}Opción inválida: -$OPTARG${NC}" >&2; uso ;;
     :) echo -e "${RED}La opción -$OPTARG requiere un argumento.${NC}" >&2; uso ;;
  esac
done


# Modo interactivo si no se proporciona la opción -u
if [ "$modo_interactivo" = true ]; then
  # Obtener entrada del usuario
  read -p "Ingresa el día de la semana en el cual iniciar (Mon, Tue, Wed, etc. Opcional, ingresa * o presiona Enter para no ingresar un día): " user_weekday
  read -p "Ingresa la hora a la cual iniciar (0-23): " user_hour
  read -p "Ingresa el minuto en el cual iniciar (0-59): " user_min
  read -p "Ingresa el numero de día en el cual iniciar (1-31,*) Ingresa * para realizarlo todos los días que cumplan con el resto de criterios: " user_day
  read -p "Ingresa el mes en el cual iniciar (1-12,*)  Ingresa * para realizarlo todos los meses que cumplan con el resto de criterios: " user_month
  echo Imagenes disponibles
  column_values=($(ls -d "$repo"*-img | xargs -I {} basename {} '-img'))
  PS3="Elegí una imagen: "
  select user_image in "${column_values[@]}"; do
      if [[ -n user_image ]]; then
              images=($(awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg ))
              if [[ "${images[@]}" =~ .*Restore."$user_image".* ]]; then
                        echo "Seleccionaste la Imagen: $user_image"
               else
                        echo "La imagen no se encuentran añadida, añadiendo imagen.."
                        sudo bash "$SCRIPT_DIR"/add_image_auto.sh -i "$user_image"
              fi
              break
      else
              echo "Opcion invalida."
          fi
      done


  read -p "¿Quieres habilitar la opción de reintentar? (s/n, por defecto: n): " retry_input
#  read -p "¿Quieres habilitar la opción de ejecución única? (s/n, por defecto: n): " onetimeonly_input

  case $retry_input in
    [sS]) retry=true ;;
  esac

  case $onetimeonly_input in
    [sS]) onetimeonly=true ;;
  esac
  # Asignar valores ingresados por el usuario (si están presentes)
  [[ -n "$user_day" ]] && { validar_dia "$user_day"; day="$user_day"; }
  [[ -n "$user_weekday" ]] && { validar_dia_semana "$user_weekday"; weekday="$user_weekday"; }
  [[ -n "$user_hour" ]] && { validar_hora "$user_hour"; hour="$user_hour"; }
  [[ -n "$user_min" ]] && { validar_minuto "$user_min"; min="$user_min"; }
  [[ -n "$user_month" ]] && { validar_mes "$user_month"; month="$user_month"; }
  [[ -n "$user_image" ]] && { validar_nombre_imagen "$user_image"; image_name="$user_image"; }


fi



# Verificar si -i no está presente e image_name no está especificado
if [ -z "$image_name" ]; then
  echo Imagenes disponibles
  column_values=($(ls -d "$repo"*-img | xargs -I {} basename {} '-img'))
  # Prompt user with autocompletion
  PS3="Elegí una imagen: "
  select image_name in "${column_values[@]}"; do
      if [[ -n $image_name ]]; then
              images=($(awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg ))
              if [[ "${images[@]}" =~ .*Restore."$image_name".* ]]; then
                        echo "Seleccionaste la Imagen: $image_name"
              else
                        echo "La imagen no se encuentran añadida, añadiendo imagen.."
                        sudo bash "$SCRIPT_DIR"/add_image_auto.sh -i "$image_name"
              fi
              break
      else
              echo "Opcion invalida."
          fi
      done

fi


echo "Es la imagen un disco o una partición?"
echo "1. Disco"
echo "2. Partición"
read opcion


case $opcion in
        1) values=$(awk -F ',' '{print $7}' "$SCRIPT_DIR/log/log.csv" | sort | uniq)

        for disk in $values; do
            date_str="1900-$month-$day $hour:$min:00"
            cron_line="$min $hour $day $month $weekday bash $SCRIPT_DIR/Restore.sh -i $image_name -d "$disk""

if [ "$repair_mode" = true ]; then
  cron_line="$cron_line -f"
fi

if [ "$retry" = true ]; then
  cron_line="$cron_line -r"
fi

if [ "$onetimeonly" = true ]; then
  cron_line="$cron_line -o"
fi

temp_file=$(mktemp)

sudo crontab -l -u root > "$temp_file"


echo "$cron_line" >> "$temp_file"

sudo crontab -u root "$temp_file"


rm "$temp_file"


echo Se agregó "$cron_line"



new_date=$(date -d "$date_str $increment minutes" "+%m-%d %H:%M")
newday=$(echo "$new_date" | cut -d'-' -f2 | cut -d' ' -f1)


if [ "$weekday" != "*" ] && [ "$day" != "$new_day" ]; then
    case $weekday in
        Mon) weekday=Tue ;;
        Tue)  weekday=Wed ;;
        Wed) weekday=Thu ;;
        Thu) weekday=Fri ;;
        Fri)  weekday=Sat ;;
        Sat)  weekday=Sun ;;
        Sun)  weekday=Mon ;;
    esac

fi





month=$(echo "$new_date" | cut -d'-' -f1)
day=$(echo "$new_date" | cut -d'-' -f2 | cut -d' ' -f1)
hour=$(echo "$new_date" | cut -d' ' -f2 | cut -d':' -f1)
min=$(echo "$new_date" | cut -d':' -f2)

done
               ;;
        2)values=$(awk -F ',' '{print $8}' "$SCRIPT_DIR/log/log.csv" | sort | uniq)

        for partition in $values; do
            date_str="1900-$month-$day $hour:$min:00"
            cron_line="$min $hour $day $month $weekday bash $SCRIPT_DIR/Restore.sh -i $image_name -d "$partition""

if [ "$repair_mode" = true ]; then
  cron_line="$cron_line -f"
fi

if [ "$retry" = true ]; then
  cron_line="$cron_line -r"
fi

if [ "$onetimeonly" = true ]; then
  cron_line="$cron_line -o"
fi

temp_file=$(mktemp)

sudo crontab -l -u root > "$temp_file"


echo "$cron_line" >> "$temp_file"

sudo crontab -u root "$temp_file"


rm "$temp_file"


echo Se agregó "$cron_line"


new_date=$(date -d "$date_str $increment minutes" "+%m-%d %H:%M")
newday=$(echo "$new_date" | cut -d'-' -f2 | cut -d' ' -f1)


if [ "$weekday" != "*" ] && [ "$day" != "$new_day" ]; then
    case $weekday in
        Mon) weekday=Tue ;;
        Tue)  weekday=Wed ;;
        Wed) weekday=Thu ;;
        Thu) weekday=Fri ;;
        Fri)  weekday=Sat ;;
        Sat)  weekday=Sun ;;
        Sun)  weekday=Mon ;;
    esac

fi



month=$(echo "$new_date" | cut -d'-' -f1)
day=$(echo "$new_date" | cut -d'-' -f2 | cut -d' ' -f1)
hour=$(echo "$new_date" | cut -d' ' -f2 | cut -d':' -f1)
min=$(echo "$new_date" | cut -d':' -f2)

done

                ;;
esac





