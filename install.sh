cat > ~/Projects/Arch95/install.sh << 'EOF'
#!/bin/bash

set -e

APP="Arch95 Installer"

msg() {
  zenity --info --title="$APP" --text="$1" --width=360 2>/dev/null || echo "$1"
}

ask() {
  zenity --question --title="$APP" --text="$1" --width=360 2>/dev/null
}

if ! command -v zenity >/dev/null 2>&1; then
  echo "Zenity não encontrado. Instale com:"
  echo "sudo pacman -S zenity"
  exit 1
fi

msg "Welcome to Arch95 v1.0 Beta."

OPTIONS=$(zenity --list \
  --title="$APP" \
  --text="Choose what you want to install:" \
  --checklist \
  --column="Install" --column="Component" \
  TRUE "GTK/XFCE Theme" \
  TRUE "Arch95 Volume Script" \
  TRUE "Apply XFCE Theme" \
  FALSE "Apply Multimedia Shortcuts" \
  FALSE "Apply Panel Config Backup" \
  --width=520 --height=320)

[ -z "$OPTIONS" ] && exit 0

mkdir -p ~/.themes
mkdir -p ~/.local/bin

if echo "$OPTIONS" | grep -q "GTK/XFCE Theme"; then
  rm -rf ~/.themes/Arch95
  cp -r theme/Arch95 ~/.themes/
fi

if echo "$OPTIONS" | grep -q "Arch95 Volume Script"; then
  cp scripts/arch95-volume ~/.local/bin/
  chmod +x ~/.local/bin/arch95-volume
fi

if echo "$OPTIONS" | grep -q "Apply XFCE Theme"; then
  xfconf-query -c xsettings -p /Net/ThemeName -s "Arch95"
  xfconf-query -c xfwm4 -p /general/theme -s "Arch95"
fi

if echo "$OPTIONS" | grep -q "Apply Multimedia Shortcuts"; then
  xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/AudioRaiseVolume -s "$HOME/.local/bin/arch95-volume up"
  xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/AudioLowerVolume -s "$HOME/.local/bin/arch95-volume down"
  xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/AudioMute -s "$HOME/.local/bin/arch95-volume mute"
  xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/AudioMicMute -s "$HOME/.local/bin/arch95-volume mic"
fi

if echo "$OPTIONS" | grep -q "Apply Panel Config Backup"; then
  msg "Panel config import is not automatic yet. Files are available in ./config/"
fi

xfce4-panel -r 2>/dev/null || true
xfdesktop --reload 2>/dev/null || true

msg "Arch95 installation complete."
EOF

chmod +x ~/Projects/Arch95/install.sh