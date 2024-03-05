#!/bin/bash
get_network() {
    local default_interface=$(ip route | awk '/default/ {print $5}')
    local local_ip=$(ip -o -4 addr show dev "$default_interface" | awk -F 'inet ' '{split($2, a, "/"); print a[1]}') 
    local network=$(echo "$local_ip" | awk -F. '{print $1"."$2"."$3".0/24"}')
    echo "$network"
}
network=$(get_network)

read -p "Ingresa el usuario de las imagenes: " usuario
sudo nmap -sn $network | grep -E "Nmap scan|MAC Address" | awk '/Nmap/{ip=$NF} /MAC Address/{print $3 "," ip}' | grep -vP '\([^)]*\)' | nl -s, -w1 | awk -v user="$usuario"  -F',' '{print $2 "," $3 "," $1 "," user "," ","}'


