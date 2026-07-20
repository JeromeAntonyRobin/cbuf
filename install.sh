#!/usr/bin/env bash

set -e

# Visual formatting
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BOLD}${BLUE}=== cbuf (Clipboard Buffer) Full Auto-Installer ===${RESET}\n"

# 1. System Package Dependency Installation
echo -e "${GREEN}[1/5] Checking and installing system packages...${RESET}"
DEPENDENCIES=(python3 xclip xdotool alacritty wget)
for pkg in "${DEPENDENCIES[@]}"; do
    if ! command -v "$pkg" &> /dev/null; then
        echo "Installing missing package: $pkg"
        sudo apt update && sudo apt install -y "$pkg"
    fi
done

# 2. Greenclip Binary Download
echo -e "${GREEN}[2/5] Setting up greenclip daemon binary...${RESET}"
if [ ! -f /usr/local/bin/greenclip ]; then
    echo "Downloading official greenclip executable..."
    sudo wget -O /usr/local/bin/greenclip https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
    sudo chmod +x /usr/local/bin/greenclip
fi

# 3. Systemd Background Service Automation
echo -e "${GREEN}[3/5] Configuring greenclip systemd background service...${RESET}"
mkdir -p "$HOME/.config/systemd/user/"

cat << 'EOF' > "$HOME/.config/systemd/user/greenclip.service"
[Unit]
Description=Greenclip Clipboard Daemon
After=xorg.target

[Service]
Type=simple
ExecStart=/usr/local/bin/greenclip daemon
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable greenclip.service --now

# 4. Binary Deployment
echo -e "${GREEN}[4/5] Deploying cbuf script engine...${RESET}"
mkdir -p "$HOME/bin"
cp ./bin/cbuf "$HOME/bin/cbuf"
chmod +x "$HOME/bin/cbuf"

# 5. Automated Keybinding Override (Super + V)
echo -e "${GREEN}[5/5] Configuring GNOME Super+V global shortcut...${RESET}"

# Clear GNOME message tray conflict
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']" 2>/dev/null || true

# Set up the custom shortcut target
SLOT="custom2"
BASE_KEY="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${SLOT}/"
CMD_STR="alacritty --class clipboard-popup,FloatingClipboard -o window.dimensions.columns=240 -o window.dimensions.lines=12 -o window.decorations=\"None\" -e /home/$USER/bin/cbuf"

gsettings set "${BASE_KEY}" name 'cbuf Clipboard Buffer'
gsettings set "${BASE_KEY}" command "${CMD_STR}"
gsettings set "${BASE_KEY}" binding '<Super>v'

# Register custom slot to GNOME keybinding registry
CURRENT_BINDINGS=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
if [[ "$CURRENT_BINDINGS" != *"custom2"* ]]; then
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
fi

echo -e "\n${BOLD}${GREEN}=== cbuf Installation Complete! ===${RESET}"
echo -e "Press ${BOLD}Super + V${RESET} anywhere to drop the clipboard curtain!"