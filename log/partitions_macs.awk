BEGIN { FS = "," }
$8 == filter { print $1 }
