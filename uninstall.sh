#!/usr/bin/env bash

set -e

# Visual formatting
BOLD="\033[1m"
RED="\033[31m"
BLUE="\033[34m"
GREEN="\033[32m"
RESET="\033[0m"

echo -e "${BOLD}${BLUE}=== cbuf (Clipboard Buffer) Full Uninstaller ===${RESET}\n"

# 1. Stop and Disable Systemd Service
echo -e "${RED}[1/4] Disabling greenclip systemd service...${RESET}"
if systemctl --user is-active --quiet greenclip.service 2>/dev/null; then
    systemctl --user stop greenclip.service
fi
if systemctl --user is-enabled --quiet greenclip.service 2>/dev/null; then
    systemctl --user disable greenclip.service
fi
rm -f "$HOME/.config/systemd/user/greenclip.service"
systemctl --user daemon-reload

# 2. Reset GNOME Keybindings
echo -e "${RED}[2/4] Restoring GNOME keybindings...${RESET}"

# Restore Super+V / Super+M default tray behavior
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v', '<Super>m']" 2>/dev/null || true

# Reset custom hotkey slot custom2
SLOT="custom2"
BASE_KEY="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${SLOT}/"
gsettings reset "${BASE_KEY}" name 2>/dev/null || true
gsettings reset "${BASE_KEY}" command 2>/dev/null || true
gsettings reset "${BASE_KEY}" binding 2>/dev/null || true

# 3. Clean Binary and Virtualenv Data
echo -e "${RED}[3/4] Purging cbuf executable and virtual environment...${RESET}"
rm -f "$HOME/bin/cbuf"
rm -rf "$HOME/.local/share/cbuf"

# 4. Optional Greenclip Binary Cleanup
echo -e "${RED}[4/4] Finalizing cleanup...${RESET}"
if [ -f /usr/local/bin/greenclip ]; then
    read -p "Do you want to remove the system daemon binary (/usr/local/bin/greenclip)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo rm -f /usr/local/bin/greenclip
        echo -e "${GREEN}Removed /usr/local/bin/greenclip${RESET}"
    fi
fi

echo -e "\n${BOLD}${GREEN}=== cbuf Uninstallation Complete! ===${RESET}"
echo -e "Your keybindings and system processes have been restored cleanly."