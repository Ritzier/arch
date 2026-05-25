file="$HOME/.config/polybar/config.ini"

echo "[+] Updating Polybar modules-right..."

# Comment the 12tbfilesystem version
sed -i \
    's/^modules-right = left cpu memory filesystem 12tbfilesystem 10tbfilesystem right$/# modules-right = left cpu memory filesystem 12tbfilesystem 10tbfilesystem right/' \
    "$file"

# Uncomment battery-script version
sed -i \
    's/^# modules-right = left cpu memory filesystem battery-script right$/modules-right = left cpu memory filesystem battery-script right/' \
    "$file"

echo "[✓] Polybar modules updated"
