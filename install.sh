#!/usr/bin/env bash

set -e

# Visual formatting
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BOLD}${BLUE}=== cbuf (Clipboard Buffer) Full Auto-Installer ===${RESET}\n"

# 1. System Package Dependency Installation
echo -e "${GREEN}[1/6] Checking and installing system packages...${RESET}"
DEPENDENCIES=(python3 python3-pip python3-venv xclip xdotool alacritty wget)
for pkg in "${DEPENDENCIES[@]}"; do
    if ! command -v "$pkg" &> /dev/null && ! dpkg -l | grep -q "$pkg"; then
        echo "Installing missing system package: $pkg"
        sudo apt update && sudo apt install -y "$pkg"
    fi
done

# 2. Python Virtual Environment & PIP Setup
echo -e "${GREEN}[2/6] Setting up Python virtual environment & PIP dependencies...${RESET}"
CBUF_VENV_DIR="$HOME/.local/share/cbuf/venv"
mkdir -p "$HOME/.local/share/cbuf"

if [ ! -d "$CBUF_VENV_DIR" ]; then
    python3 -m venv "$CBUF_VENV_DIR"
fi

# Upgrade pip and install optional/required packages inside isolated venv
"$CBUF_VENV_DIR/bin/pip" install --upgrade pip setuptools wheel

# If you create a requirements.txt later, it will automatically install from it here
if [ -f "./requirements.txt" ]; then
    echo "Installing requirements from requirements.txt..."
    "$CBUF_VENV_DIR/bin/pip" install -r ./requirements.txt
fi

# 3. Greenclip Binary Download
echo -e "${GREEN}[3/6] Setting up greenclip daemon binary...${RESET}"
if [ ! -f /usr/local/bin/greenclip ]; then
    echo "Downloading official greenclip executable..."
    sudo wget -O /usr/local/bin/greenclip https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
    sudo chmod +x /usr/local/bin/greenclip
fi

# 4. Systemd Background Service Automation
echo -e "${GREEN}[4/6] Configuring greenclip systemd background service...${RESET}"
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

# 5. Binary Deployment & Wrapper Script
echo -e "${GREEN}[5/6] Deploying cbuf executable engine...${RESET}"
mkdir -p "$HOME/bin"

# Write wrapper script so cbuf always uses its dedicated Python virtual environment
cat << EOF > "$HOME/bin/cbuf"
#!/usr/bin/env bash
exec "$CBUF_VENV_DIR/bin/python3" "$HOME/.local/share/cbuf/cbuf.py" "\$@"
EOF

cp ./bin/cbuf "$HOME/.local/share/cbuf/cbuf.py"
chmod +x "$HOME/bin/cbuf"
chmod +x "$HOME/.local/share/cbuf/cbuf.py"

# 6. Automated Keybinding Override (Super + V)
echo -e "${GREEN}[6/6] Configuring GNOME Super+V global shortcut...${RESET}"

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
