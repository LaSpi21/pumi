#!/bin/bash
read -p "Ingresa el usuario de las imagenes: " usuario
sudo nmap -sn 10.1.181.0/24 | grep -E "Nmap scan|MAC Address" | awk '/Nmap/{ip=$NF} /MAC Address/{print $3 "," ip}' | grep -vP '\([^)]*\)' | nl -s, -w1 | awk -v user="$usuario"  -F',' '{print $2 "," $3 "," $1 "," user "," ","}'


