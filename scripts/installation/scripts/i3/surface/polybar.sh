file="$HOME/.config/polybar/config.ini"

echo "[+] Updating Polybar modules-right..."

sed -i \
    -e 's/^modules-right = left cpu memory filesystem 12tbfilesystem right$/# modules-right = left cpu memory filesystem 12tbfilesystem right/' \
    -e 's/^# modules-right = left cpu memory filesystem battery-script right$/modules-right = left cpu memory filesystem battery-script right/' \
    $file

echo "[✓] Polybar modules updated"
