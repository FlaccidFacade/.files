#!/usr/bin/env bash
set -Eeuo pipefail

BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['${BASE}/custom0/']"
gsettings set ${BASE}/custom-keybinding:/ name 'Sleep'
gsettings set ${BASE}/custom-keybinding:/ command 'systemctl suspend'
gsettings set ${BASE}/custom-keybinding:/ binding '<Super>z'

echo "GNOME sleep hotkey bound: Super+z"