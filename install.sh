#!/usr/bin/env bash

set -e

BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${BLUE}=== cbuf (Clipboard Buffer) Full Auto-Installer ===${RESET}\n"

# 1. System Package Dependency Installation
echo -e "${GREEN}[1/7] Checking and installing system packages...${RESET}"
DEPENDENCIES=(python3 python3-pip python3-venv xclip xdotool alacritty wget)
for pkg in "${DEPENDENCIES[@]}"; do
    if ! command -v "$pkg" &> /dev/null && ! dpkg -l | grep -q "$pkg"; then
        echo "Installing missing system package: $pkg"
        sudo apt update && sudo apt install -y "$pkg"
    fi
done

# 2. Python Virtual Environment Setup
echo -e "${GREEN}[2/7] Setting up Python virtual environment...${RESET}"
CBUF_VENV_DIR="$HOME/.local/share/cbuf/venv"
mkdir -p "$HOME/.local/share/cbuf"

if [ ! -d "$CBUF_VENV_DIR" ]; then
    python3 -m venv "$CBUF_VENV_DIR"
fi

"$CBUF_VENV_DIR/bin/pip" install --upgrade pip setuptools wheel > /dev/null

if [ -f "./requirements.txt" ]; then
    echo "Installing requirements from requirements.txt..."
    "$CBUF_VENV_DIR/bin/pip" install -r ./requirements.txt
fi

# 3. Dedicated Borderless Alacritty Profile Deployment
echo -e "${GREEN}[3/7] Deploying borderless Alacritty profile...${RESET}"
mkdir -p "$HOME/.config/alacritty"
cat << 'EOF' > "$HOME/.config/alacritty/cbuf-alacritty.toml"
[window]
decorations = "None"
opacity = 0.98
dynamic_padding = true

[window.dimensions]
columns = 240
lines = 12

[font]
size = 11.0
EOF

# 4. Greenclip Binary Download
echo -e "${GREEN}[4/7] Setting up greenclip daemon binary...${RESET}"
if [ ! -f /usr/local/bin/greenclip ]; then
    echo "Downloading official greenclip executable..."
    sudo wget -O /usr/local/bin/greenclip https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
    sudo chmod +x /usr/local/bin/greenclip
fi

# 5. Systemd Background Service Automation
echo -e "${GREEN}[5/7] Configuring greenclip systemd background service...${RESET}"
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

# 6. Binary Deployment & Source Detection
echo -e "${GREEN}[6/7] Deploying cbuf engine...${RESET}"
mkdir -p "$HOME/bin"

SRC_FILE=""
for target in "./bin/cbuf" "./cbuf.py" "./cbuf" "./alacritty-clipboard.py" "$HOME/bin/alacritty-clipboard.py"; do
    if [ -f "$target" ]; then
        SRC_FILE="$target"
        break
    fi
done

if [ -z "$SRC_FILE" ]; then
    echo -e "${RED}[-] Source script not found in current directory!${RESET}"
    echo "Please ensure your main script exists as 'cbuf.py' or 'bin/cbuf'."
    exit 1
fi

echo "Deploying source from: $SRC_FILE"
cp "$SRC_FILE" "$HOME/.local/share/cbuf/cbuf.py"
chmod +x "$HOME/.local/share/cbuf/cbuf.py"

# Write execution wrapper
cat << EOF > "$HOME/bin/cbuf"
#!/usr/bin/env bash
exec "$CBUF_VENV_DIR/bin/python3" "$HOME/.local/share/cbuf/cbuf.py" "\$@"
EOF

chmod +x "$HOME/bin/cbuf"

# 7. Automated Keybinding Override (Super + V)
echo -e "${GREEN}[7/7] Configuring GNOME Super+V global shortcut...${RESET}"

gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']" 2>/dev/null || true

SLOT="custom2"
BASE_KEY="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${SLOT}/"
CMD_STR="alacritty --class clipboard-popup,FloatingClipboard --config-file $HOME/.config/alacritty/cbuf-alacritty.toml -e $HOME/bin/cbuf"

gsettings set "${BASE_KEY}" name 'cbuf Clipboard Buffer'
gsettings set "${BASE_KEY}" command "${CMD_STR}"
gsettings set "${BASE_KEY}" binding '<Super>v'

CURRENT_BINDINGS=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
if [[ "$CURRENT_BINDINGS" != *"custom2"* ]]; then
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
fi

echo -e "\n${BOLD}${GREEN}=== cbuf Installation Complete! ===${RESET}"
echo -e "Press ${BOLD}Super + V${RESET} anywhere to drop the borderless clipboard curtain!"
