#!/bin/bash

arg="$1"
sudo R -q -e "install.packages('$arg')"

