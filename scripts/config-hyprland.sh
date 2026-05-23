#!/bin/bash
# =============================================================================
# TérangaOS - Configuration Hyprland
# Basé sur terangaos_complete.html
# =============================================================================

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_CONFIG_DIR="$TERANGA_DIR/config/includes.chroot/etc/skel/.config/hypr"

echo "[INFO] Configuration Hyprland pour TérangaOS..."

mkdir -p "$HYPR_CONFIG_DIR"

# =============================================================================
# hyprland.conf - Configuration principale
# =============================================================================
cat > "$HYPR_CONFIG_DIR/hyprland.conf" << 'EOF'
# ═══════════════════════════════════════════════════════════
# TérangaOS — Hyprland Configuration
# Codename: Djolof | ESP/UCAD Dakar
# Version: 1.0
# ═══════════════════════════════════════════════════════════

# Monitor
monitor=,preferred,auto,1

# Autostart
exec-once = hyprpaper
exec-once = waybar
exec-once = mako
exec-once = nm-applet --indicator
exec-once = udiskie -t
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = wl-paste --type text --watch cliphist store

# Environment
env = XCURSOR_SIZE,24
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = GDK_BACKEND,wayland,x11
env = QT_QPA_PLATFORM,wayland;xcb
env = MOZ_ENABLE_WAYLAND,1

# ── APPARENCE ──
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(FFBE00ff) rgba(C85200ff) 45deg
    col.inactive_border = rgba(1A1408aa)
    layout = dwindle
    allow_tearing = false
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 6
        passes = 3
        new_optimizations = true
        xray = false
    }
    drop_shadow = true
    shadow_range = 20
    col.shadow = rgba(FFBE0022)
    active_opacity = 1.0
    inactive_opacity = 0.92
}

animations {
    enabled = true
    bezier = overshot, 0.05, 0.9, 0.1, 1.05
    bezier = smoothOut, 0.36, 0, 0.66, 1
    bezier = smoothIn, 0.25, 1, 0.5, 1

    animation = windows, 1, 7, overshot, slide
    animation = windowsOut, 1, 7, smoothIn, slide
    animation = border, 1, 10, default
    animation = border, 1, 10, default
    animation = fade, 1, 7, smoothIn
    animation = fade, 1, 7, smoothOut
    animation = workspaces, 1, 6, default
}

# ── LAYOUTS ──
dwindle {
    pseudotile = true
    preserve_split = true
    no_gaps_when_only = false
}

master {
    new_status = master
}

# ── GESTURE ──
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
}

# ── INPUT ──
input {
    kb_layout = fr
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1
    sensitivity = 0

    touchpad {
        natural_scroll = true
        disable_while_typing = true
    }
}

# ── WINDOW RULES ──
windowrulev2 = float, class:^(pavucontrol)$, title:^(Volume Control)$
windowrulev2 = float, class:^(nm-connection-editor)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = float, class:^(yad)$
windowrulev2 = opacity 0.90 0.90, class:^(kitty)$

# ── KEYBINDINGS ──
$mainMod = SUPER
$terminal = kitty
$menu = wofi --show drun

# Main
bind = $mainMod, Return, exec, $terminal
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen, 0

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, left, workspace, e+1
bind = $mainMod, right, workspace, e-1

# Move focus
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

# Screenshot
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy

# Window grouping
bind = $mainMod, G, togglegroup
bind = $mainMod, Tab, changegroupactive, f

# ── NECESSARY ════════════════════════════════════════════
layerrule = ignorezero, waybar
layerrule = ignorezero, notifications
layerrule = ignorezero, notification shell
wsbar = [workspace 2], exec, waybar

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    mouse_move_enables_dpms = true
    key_press_enables_dpms = true
}

# ── BLUR ──
blurls = lockscreen
blurls = waybar
blurls = notifications
blurls = notification-shell
blurls = wsp-blur

# ── VULKAN ──
env = LIBVA_DRIVER_NAME,zink
env = AMD_VULKAN_ICD,RADV
env = RADV_PERFTEST,aco
EOF

echo "[OK] hyprland.conf créé"
EOF

# =============================================================================
# hyprpaper.conf
# =============================================================================
cat > "$HYPR_CONFIG_DIR/hyprpaper.conf" << 'EOF'
preload = /usr/share/backgrounds/terangaos/teranga-wallpaper.png
wallpaper = ,/usr/share/backgrounds/terangaos/teranga-wallpaper.png
splash = false
EOF

# =============================================================================
# hyprlock.conf
# =============================================================================
cat > "$HYPR_CONFIG_DIR/hyprlock.conf" << 'EOF'
background {
    monitor =
    path = /usr/share/backgrounds/terangaos/teranga-wallpaper.png
    blur_pixels = 4
}

label {
    monitor =
    text = TérangaOS
    color = rgba(FFBE00ff)
    font_size = 48
    font_family = JetBrains Mono
    position = 0, -100
    halign = center
}

input-field {
    monitor =
    size = 300, 50
    position = 0, 100
    halign = center
    outline_thickness = 2
    inner_padding = 20
    cap_style = round
    placeholder_text = Password
    hide_input = true
}
EOF

echo "[OK] Configuration Hyprland créée"
