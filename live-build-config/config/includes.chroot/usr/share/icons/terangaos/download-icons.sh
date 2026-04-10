#!/bin/bash
# =============================================================================
# TérangaOS - Téléchargeur d'Icons Professionnel
# Icônes basées sur Papirus (MIT License)
# =============================================================================

ICONS_DIR="/usr/share/icons/terangaos"
mkdir -p "$ICONS_DIR"/{apps,places,status}

echo "[TERANGOS] Téléchargement icons Papirus..."

# Base URL for Papirus icons (GitHub release)
PAPIRUS_BASE="https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/Papirus"

download_icon() {
    local src="$1"
    local dest="$2"
    local size="$3"
    
    local url="$PAPIRUS_BASE-$size/$src"
    local path="$ICONS_DIR/$dest"
    
    mkdir -p "$(dirname "$path")"
    curl -L -o "$path" "$url" 2>/dev/null && echo "[OK] $dest" || echo "[SKIP] $dest"
}

# Download essential system icons
download_icon "terminal-firefox.svg" "apps/firefox.svg" "16x16"
download_icon "terminal-firefox.svg" "apps/firefox.svg" "32x32"
download_icon "utilities-terminal.svg" "apps/terminal.svg" "16x16"
download_icon "utilities-terminal.svg" "apps/terminal.svg" "32x32"
download_icon "org.freedesktop.NetworkManager.svg" "apps/network.svg" "16x16"
download_icon "preferences-system.svg" "apps/settings.svg" "16x16"
download_icon "system-file-manager.svg" "apps/file-manager.svg" "16x16"
download_icon "text-editor.svg" "apps/text-editor.svg" "16x16"
download_icon "accessories-calculator.svg" "apps/calculator.svg" "16x16"
download_icon "audio-volume-high.svg" "status/audio-volume-high.svg" "16x16"
download_icon "audio-volume-medium.svg" "status/audio-volume-medium.svg" "16x16"
download_icon "audio-volume-low.svg" "status/audio-volume-low.svg" "16x16"
download_icon "audio-volume-muted.svg" "status/audio-volume-muted.svg" "16x16"
download_icon "battery-good.svg" "status/battery-good.svg" "16x16"
download_icon "battery-low.svg" "status/battery-low.svg" "16x16"
download_icon "network-wireless-connected.svg" "status/network-wireless.svg" "16x16"
download_icon "network-offline.svg" "status/network-offline.svg" "16x16"

# Create index.theme
cat > "$ICONS_DIR/index.theme" << 'EOF'
[Icon Theme]
Name=TérangaOS
Comment=TérangaOS Djolof Icon Theme
Inherits=hicolor,adwaita, papirus
Directories=apps,places,status

[apps]
Size=16
Context=Apps
Type=Fixed

[places]
Size=16
Context=Places
Type=Fixed

[status]
Size=16
Context=Status
Type=Fixed
EOF

echo "[OK] Icônes téléchargées"