#!/bin/bash
# =============================================================================
# TérangaOS - Configuration Desktop (Kitty, Wofi, Mako, SDDM)
# =============================================================================

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_BASE="$TERANGA_DIR/config/includes.chroot/etc/skel/.config"
mkdir -p "$CONFIG_BASE/kitty" "$CONFIG_BASE/wofi" "$CONFIG_BASE/mako"

echo "[INFO] Configuration Desktop..."

# =============================================================================
# kitty.conf
# =============================================================================
cat > "$CONFIG_BASE/kitty/kitty.conf" << 'EOF'
# ═══════════════════════════════════════════════════════════
# TérangaOS — Kitty Terminal Configuration
# ═══════════════════════════════════════════════════════════

# Font
font_family      JetBrains Mono Medium
bold_font        JetBrains Mono Bold
italic_font      JetBrains Mono Medium Italic
bold_italic_font JetBrains Mono Bold Italic
font_size        13.0
line_height      1.2

# Colors - TérangaOS Dark Gold
background            #0a0702
foreground            #F5EDD8
cursor                #FFBE00
cursor_text_color     #0a0702

# Tabs
tab_bar_edge          top
tab_bar_style         powerline
tab_powerline_style   angled
active_tab_background #1A1408
active_tab_foreground #FFBE00
inactive_tab_background #0a0702
inactive_tab_foreground #666666

# Selection
selection_background #FFBE0044
selection_foreground #F5EDD8

# Window
window_padding_width  8
window_border_width   1px
window_margin_width   0
active_border_color   #FFBE00
inactive_border_color #1A1408

# Scrollback
scrollback_lines      10000

# Bell
enable_audio_bell     no
window_alert_on_bell  yes

# Performance
repaint_delay          10
input_delay            3
sync_to_monitor        yes

# Shell
shell -zsh

# Keybindings
kitty_mod ctrl+shift

# Open URL
open_url_with default

# Clipboard
copy_on_select yes
strip_trailing_spaces always

# Cursor
cursor_shape block
cursor_blink yes
cursor_stop_blinking_after 15.0

# Mouse
click_url_or_select_hint yes
open_url_with double_click
EOF

# =============================================================================
# wofi/config
# =============================================================================
cat > "$CONFIG_BASE/wofi/config" << 'EOF'
# TérangaOS Wofi Configuration

width=600
height=400
location=center
show=drun
prompt=Rechercher...
insensitive=true
allow_markup=true
no_actions=true
halign=fill
orientation=vertical
content_halign=fill
filter_rate=100
allow_images=true
image_size=32
gtk_dark=true
EOF

# =============================================================================
# wofi/style.css
# =============================================================================
cat > "$CONFIG_BASE/wofi/style.css" << 'EOF'
window {
    margin: 0px;
    border: 1px solid #FFBE0033;
    background-color: rgba(10, 7, 2, 0.95);
    border-radius: 8px;
    font-family: "JetBrains Mono", monospace;
    font-size: 13px;
    color: #F5EDD8;
}

#input {
    margin: 8px;
    padding: 10px;
    border: 1px solid #FFBE0044;
    border-radius: 6px;
    background-color: #1A1408;
    color: #F5EDD8;
    font-family: "JetBrains Mono", monospace;
}

#input:focus {
    border: 1px solid #FFBE00;
    outline: none;
}

#inner-box {
    margin: 8px;
    border: none;
    background-color: transparent;
}

#outer-box {
    margin: 0px;
    border: none;
    background-color: transparent;
}

#scroll {
    margin: 4px;
}

#text {
    padding: 8px 12px;
    border-radius: 4px;
    color: #F5EDD8;
}

#text:selected {
    background-color: #FFBE0022;
    text-color: #FFBE00;
}

#entry {
    padding: 6px;
    border-radius: 4px;
}

#entry:selected {
    background-color: rgba(255, 190, 0, 0.15);
}

#text:selected {
    color: #FFBE00;
}
EOF

# =============================================================================
# mako/config
# =============================================================================
cat > "$CONFIG_BASE/mako/config" << 'EOF'
# TérangaOS Mako Notifications

max-visible=5
sort=-time
layer=overlay
anchor=top
width=350
height=150
margin=10
padding=15
border-size=1px
border-radius=8px
border-color=#FFBE0044
background-color=#1A1408ee
text-color=#F5EDD8
default-timeout=5000
font=JetBrains Mono 11px

[urgency=low]
border-color=#4FFFAA44
background-color=#1A1408cc

[urgency=normal]
border-color=#FFBE0044
background-color=#1A1408ee

[urgency=high]
border-color=#FF6B6B88
background-color=#1A1408ff
default-timeout=0
EOF

# =============================================================================
# sddm.conf
# =============================================================================
mkdir -p "$TERANGA_DIR/config/includes.chroot/etc/sddm.conf.d"
cat > "$TERANGA_DIR/config/includes.chroot/etc/sddm.conf.d/teranga.conf" << 'EOF'
[Theme]
Current= breeze
CursorTheme= Adwaita
Font= JetBrains Mono
X11ursorTheme= Adwaita

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
Numlock=on

[Autologin]
User=teranga
Session=hyprland.desktop
EOF

echo "[OK] Configuration Desktop créée"
