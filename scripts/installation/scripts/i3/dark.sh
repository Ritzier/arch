# Gnome
gsettings set org.gnome.desktop.interface gtk-theme 'Breeze-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

plasma-apply-lookandfeel --apply org.kde.breezedark.desktop

kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
