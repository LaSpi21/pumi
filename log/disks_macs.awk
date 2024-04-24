BEGIN { FS = "," }
$7 == filter { print $1 }
