#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'

cat <(sudo crontab -l | grep -v '^#' | awk NF)

