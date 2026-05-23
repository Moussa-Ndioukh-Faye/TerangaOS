#!/bin/bash
# =============================================================================
# TérangaOS - Configuration Waybar
# Basé sur terangaos_complete.html
# =============================================================================

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAYBAR_DIR="$TERANGA_DIR/config/includes.chroot/etc/skel/.config/waybar"
mkdir -p "$WAYBAR_DIR"

echo "[INFO] Configuration Waybar..."

# =============================================================================
# config.jsonc
# =============================================================================
cat > "$WAYBAR_DIR/config.jsonc" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "spacing": 8,
    "exclusive": true,
    
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["idle_inhibitor", "pulseaudio", "network", "cpu", "memory", "temperature", "battery", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": false,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "一",
            "2": "二",
            "3": "三",
            "4": "四",
            "5": "五",
            "urgent": "",
            "focused": "●",
            "default": "○"
        },
        "persistent-workspaces": {
            "1": [],
            "2": [],
            "3": [],
            "4": [],
            "5": []
        }
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50,
        "separate-outputs": true
    },
    
    "clock": {
        "timezone": "Africa/Dakar",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format": "{:%H:%M}",
        "format-alt": "{:%d/%m/%Y — %H:%M}",
        "interval": 5
    },
    
    "cpu": {
        "format": " {usage}%",
        "tooltip": false,
        "on-click": "kitty htop"
    },
    
    "memory": {
        "format": " {}%",
        "tooltip": false,
        "on-click": "kitty htop"
    },
    
    "temperature": {
        "thermal-zone": 2,
        "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
        "critical-threshold": 80,
        "format-critical": " {temperatureC}°C",
        "format": "{icon} {temperatureC}°C",
        "format-icons": ["", "", ""]
    },
    
    "battery": {
        "states": {
            "good": 95,
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-alt": "{icon} {time}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": " {essid} ({signalStrength}%)",
        "format-ethernet": " {ipaddr}/{cidr}",
        "tooltip-format": " {ifname} via {gwaddr}",
        "format-linked": " {ifname} (No IP)",
        "format-disconnected": "⚠ Disconnected",
        "format-alt": "{ifname}: {ipaddr}/{cidr}",
        "interval": 5
    },
    
    "pulseaudio": {
        "scroll-step": 5,
        "format": "{icon} {volume}%",
        "format-bluetooth": "{icon} {volume}%",
        "format-bluetooth-muted": " muted",
        "format-muted": " muted",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    
    "tray": {
        "icon-size": 16,
        "spacing": 10
    },
    
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        },
        "tooltip": true,
        "tooltip-format-activated": "Wayland screensaver inhibited",
        "tooltip-format-deactivated": "Wayland screensaver ready"
    }
}
EOF

# =============================================================================
# style.css
# =============================================================================
cat > "$WAYBAR_DIR/style.css" << 'EOF'
/* TérangaOS Waybar - Thème Or/Sombre */

* {
    border: none;
    border-radius: 0;
    font-family: "JetBrains Mono", "Font Awesome 6 Free", monospace;
    font-size: 12px;
    min-height: 0;
}

window#waybar {
    background: rgba(10, 7, 2, 0.85);
    color: #F5EDD8;
    backdrop-filter: blur(10px);
}

#workspaces {
    margin: 0 8px;
}

#workspaces button {
    padding: 0 8px;
    color: rgba(245, 237, 216, 0.5);
    transition: all 0.3s ease;
}

#workspaces button.active {
    color: #FFBE00;
    background: rgba(255, 190, 0, 0.15);
    border-radius: 4px;
}

#workspaces button.urgent {
    color: #FF7A30;
    background: rgba(255, 122, 48, 0.2);
}

#window {
    margin: 0 16px;
    color: #F5EDD8;
    max-width: 400px;
}

#clock,
#battery,
#cpu,
#memory,
#temperature,
#backlight,
#network,
#pulseaudio,
#tray,
#mode,
#idle_inhibitor,
#mpd {
    padding: 0 12px;
    margin: 4px 2px;
    color: #F5EDD8;
}

#window {
    border-left: 2px solid #FFBE00;
    padding-left: 16px;
}

#workspaces button.focused {
    color: #FFBE00;
}

#clock {
    color: #FFBE00;
    font-weight: 600;
    font-size: 13px;
}

#battery.charging {
    color: #4FFFAA;
}

#battery.warning {
    color: #FF7A30;
}

#battery.critical {
    color: #FF6B6B;
    animation: blink 0.5s infinite;
}

#cpu {
    color: #7EC8FF;
}

#memory {
    color: #4FFFAA;
}

#temperature {
    color: #FF7A30;
}

#temperature.critical {
    color: #FF6B6B;
}

#network.disconnected {
    color: #FF6B6B;
}

#pulseaudio.muted {
    color: rgba(245, 237, 216, 0.3);
}

#idle_inhibitor.activated {
    color: #FFBE00;
}

#tray {
    color: #F5EDD8;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #FF6B6B;
}

@keyframes blink {
    0%, 100% { opacity: 1.0; }
    50% { opacity: 0.5; }
}
EOF

echo "[OK] Waybar configuré"
