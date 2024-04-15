#!/bin/bash

#Simplemente muestra en pantalla desde pumi a las acciones programadas en crontab

#Indica la ruta del archivo para ubicar de forma relativa el resto
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'

#imprime todas las entradas que no se encuentren comentadas, ToDo: dar formato amigable
cat <(sudo crontab -l | grep -v '^#' | awk NF) | nl

