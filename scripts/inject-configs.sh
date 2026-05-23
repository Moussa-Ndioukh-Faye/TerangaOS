#!/bin/bash
# =============================================================================
# TérangaOS - Scripts pour injecter les configurations
# =============================================================================

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDES="$TERANGA_DIR/config/includes.chroot"
SKEL="$INCLUDES/etc/skel"

echo "[INFO] Injection des configurations..."

mkdir -p "$SKEL/.config/hypr"
mkdir -p "$SKEL/.config/waybar"
mkdir -p "$SKEL/.config/kitty"
mkdir -p "$SKEL/.config/wofi"
mkdir -p "$SKEL/.config/mako"
mkdir -p "$SKEL/.local/share/wallpapers/terangaos"
mkdir -p "$SKEL/.oh-my-zsh/custom/themes"
mkdir -p "$INCLUDES/usr/share/backgrounds/terangaos"
mkdir -p "$INCLUDES/usr/share/grub/themes/terangaos"
mkdir -p "$INCLUDES/etc/sddm.conf.d"

# =============================================================================
# Configs Hyprland
# =============================================================================
cat > "$SKEL/.config/hypr/hyprland.conf" << 'EOF'
# TérangaOS Hyprland Config
monitor=,preferred,auto,1
exec-once = waybar
exec-once = mako
exec-once = nm-applet --indicator
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = GDK_BACKEND,wayland,x11
env = QT_QPA_PLATFORM,wayland;xcb
env = MOZ_ENABLE_WAYLAND,1
general { gaps_in=5; gaps_out=10; border_size=2; col.active_border=rgba(FFBE00ff); col.inactive_border=rgba(1A1408aa); }
decoration { rounding=10; blur{enabled=true;size=6;passes=3;} shadow_range=20; col.shadow=rgba(FFBE0022); }
animations { enabled=true; animation=windows,1,7,default,slide; animation=fade,1,7,default; }
input { kb_layout=fr; follow_mouse=1; sensitivity=0; touchpad{natural_scroll=true;} }
dwindle { pseudotile=true; preserve_split=true; }
gestures { workspace_swipe=true; }
$mainMod=SUPER; $terminal=kitty; $menu=wofi --show drun
bind=$mainMod,Return,exec,$terminal
bind=$mainMod,Q,killactive,
bind=$mainMod,E,exec,thunar
bind=$mainMod,R,exec,$menu
bind=$mainMod,1,workspace,1; bind=$mainMod,2,workspace,2; bind=$mainMod,3,workspace,3
bind=,Print,exec,grim -g "$(slurp)" - | wl-copy
misc{disable_hyprland_logo=true;disable_splash_rendering=true;}
EOF

# =============================================================================
# Configs Waybar
# =============================================================================
cat > "$SKEL/.config/waybar/config" << 'EOF'
{ "layer": "top", "position": "top", "modules-left": ["hyprland/workspaces", "hyprland/window"], "modules-center": ["clock"], "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "tray"], "hyprland/workspaces": { "format": "{icon}", "format-icons": {"1": "一", "2": "二", "3": "三", "urgent": ""} }, "clock": { "format": "{:%H:%M}", "format-alt": "{:%d/%m}", "timezone": "Africa/Dakar" }, "cpu": { "format": " {}%" }, "memory": { "format": " {}%" }, "battery": { "format": "{icon} {capacity}%", "format-icons": ["", "", ""] }, "network": { "format-wifi": " {essid}" }, "pulseaudio": { "format": "{icon} {volume}%", "format-muted": " muted" } }
EOF

cat > "$SKEL/.config/waybar/style.css" << 'EOF'
* { border: none; font-family: "JetBrains Mono"; font-size: 12px; }
window#waybar { background: rgba(10,7,2,0.85); color: #F5EDD8; }
#workspaces button.active { color: #FFBE00; background: rgba(255,190,0,0.15); border-radius: 4px; }
#clock { color: #FFBE00; font-weight: 600; }
#cpu, #memory { color: #7EC8FF; }
#battery.charging { color: #4FFFAA; }
EOF

# =============================================================================
# .zshrc
# =============================================================================
cat > "$SKEL/.zshrc" << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker)
source $ZSH/oh-my-zsh.sh
export LANG=fr_FR.UTF-8
export EDITOR=nano
alias ll='ls -la --color=auto'
alias update='sudo apt update && sudo apt upgrade -y'
alias ai='ollama run llama3.1'
echo "Bienvenue sur TérangaOS — Dalal ak diam"
EOF

# =============================================================================
# MOTD
# =============================================================================
cat > "$INCLUDES/etc/motd" << 'EOF'

  ████████╗███████╗██████╗  █████╗ ███╗  ██╗ ██████╗  █████╗
     ██╔══╝██╔════╝██╔══██╗██╔══██╗████╗ ██║██╔════╝ ██╔══██╗
     ██║   █████╗  ██████╔╝███████║██╔██╗██║██║ ████╗███████║
     ██║   ██╔══╝  ██╔══██╗██╔══██║██║╚████║██║   ██║██╔══██║
     ██║   ███████╗██║  ██║██║  ██║██║ ╚███║╚██████╔╝██║  ██║
     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚══╝ ╚═════╝ ╚═╝  ╚═╝

  Version : 1.0 (Djolof) | Base : Debian 12 Bookworm
  Piliers  : 🔒 Cybersécurité · ⚡ Développement · 🤖 IA
  Origine  : ESP/UCAD Dakar, Sénégal

  "Dalal ak diam" — Bienvenue en paix.

EOF

# =============================================================================
# os-release
# =============================================================================
cat > "$INCLUDES/etc/os-release" << 'EOF'
NAME="TérangaOS"
VERSION="1.0 (Djolof)"
ID=terangaos
ID_LIKE=debian
PRETTY_NAME="TérangaOS 1.0 (Djolof)"
ANSI_COLOR="1;33"
HOME_URL="https://esp.sn"
SUPPORT_URL="https://github.com/terangaos"
BUG_REPORT_URL="https://github.com/terangaos/issues"
VERSION_CODENAME=djolof
EOF

# =============================================================================
# Wallpaper SVG
# =============================================================================
cat > "$INCLUDES/usr/share/backgrounds/terangaos/teranga-wallpaper.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080">
  <defs>
    <radialGradient id="g1" cx="30%" cy="60%">
      <stop offset="0%" stop-color="#C85200" stop-opacity="0.4"/>
      <stop offset="100%" stop-color="#0a0702" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="g2" cx="70%" cy="30%">
      <stop offset="0%" stop-color="#FFBE00" stop-opacity="0.15"/>
      <stop offset="100%" stop-color="#0a0702" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect fill="#0a0702" width="1920" height="1080"/>
  <rect fill="url(#g1)" width="1920" height="1080"/>
  <rect fill="url(#g2)" width="1920" height="1080"/>
  <text x="960" y="520" text-anchor="middle" font-family="serif" font-size="120" font-weight="900" fill="#FFBE00" opacity="0.8">TérangaOS</text>
  <text x="960" y="600" text-anchor="middle" font-family="monospace" font-size="24" fill="#F5EDD8" opacity="0.5">Version 1.0 — Djolof</text>
</svg>
EOF

# =============================================================================
# GRUB theme
# =============================================================================
cat > "$INCLUDES/usr/share/grub/themes/terangaos/theme.txt" << 'EOF'
title-text: "TérangaOS 1.0 (Djolof)"
title-font: "JetBrains Mono Regular 24"
message-font: "JetBrains Mono Regular 14"
terminal-font: "JetBrains Mono Regular 14"

+ boot_menu {
    left = 15%
    top = 25%
    width = 70%
    height = 50%
    item_padding = 10
    item_height = 36
    
    item_color = "#F5EDD8"
    item_font = "JetBrains Mono Regular 16"
    selected_item_color = "#FFBE00"
    selected_item_font = "JetBrains Mono Bold 16"
    
    item_background = "#1A1408"
    selected_item_background = "#FFBE0022"
    
    icon_width = 32
    boot_menu_pixmap_style = "toranga_menu_*.png"
}

+ progressbar {
    left = 15%
    top = 90%
    width = 70%
    height = 8
    border_color = "#FFBE0044"
    fill_color = "#FFBE00"
}
EOF

echo "[OK] Configurations injectées"
