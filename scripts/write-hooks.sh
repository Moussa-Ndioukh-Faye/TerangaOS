#!/bin/bash
# =============================================================================
# TérangaOS - Scripts pour hooks live-build
# Basé sur terangaos_complete.html
# =============================================================================

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$TERANGA_DIR/config/hooks/live"
mkdir -p "$HOOKS_DIR"

echo "[INFO] Création des hooks live-build..."

# =============================================================================
# Hook 1: Configuration de base
# =============================================================================
cat > "$HOOKS_DIR/0001-base-config.hook.chroot" << 'EOF'
#!/bin/bash
set -e

echo "[HOOK 1/5] Configuration de base TérangaOS..."

# Hostname
echo "terangaos" > /etc/hostname
echo "127.0.1.1 terangaos" >> /etc/hosts

# Locale
echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Timezone
ln -sf /usr/share/zoneinfo/Africa/Dakar /etc/localtime
echo "Africa/Dakar" > /etc/timezone

# NetworkManager par défaut
systemctl enable NetworkManager || true

echo "[OK] Base configurée"
EOF

chmod +x "$HOOKS_DIR/0001-base-config.hook.chroot"

# =============================================================================
# Hook 2: Compilation Hyprland depuis source
# =============================================================================
cat > "$HOOKS_DIR/0002-hyprland-build.hook.chroot" << 'EOF'
#!/bin/bash
set -e

echo "[HOOK 2/5] Compilation Hyprland..."

# Dépendances Hyprland
apt-get install -y \
    libwayland-dev libwayland-egl1 libwayland-server0 \
    libxkbcommon-dev libxkbcommon-x11-dev \
    libegl1-mesa-dev libgles2-mesa-dev \
    libdrm-dev libgbm-dev \
    libpango1.0-dev libcairo2-dev \
    libseat-dev libinput-dev \
    libudev-dev libsystemd-dev \
    libpixman-1-dev libvulkan-dev glslang-dev \
    libtomlplusplus-dev librsvg2-dev \
    hwdata libdisplay-info-dev \
    meson cmake ninja-build pkg-config git curl

# Hyprland
cd /tmp
git clone --recursive https://github.com/hyprwm/Hyprland --branch v0.41.0 --depth 1
cd Hyprland
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -G Ninja
cmake --build build -j$(nproc)
cmake --install build

# Hyprpaper
cd /tmp
git clone https://github.com/hyprwm/hyprpaper --branch v0.7.0 --depth 1
cd hyprpaper
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -G Ninja
cmake --build build -j$(nproc)
cmake --install build

# Hyprlock
cd /tmp
git clone https://github.com/hyprwm/hyprlock --branch v0.5.0 --depth 1
cd hyprlock
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -G Ninja
cmake --build build -j$(nproc)
cmake --install build

rm -rf /tmp/Hyprland /tmp/hyprpaper /tmp/hyprlock
echo "[OK] Hyprland $(Hyprland --version) installé"
EOF

chmod +x "$HOOKS_DIR/0002-hyprland-build.hook.chroot"

# =============================================================================
# Hook 3: Ollama + Open WebUI + Branding
# =============================================================================
cat > "$HOOKS_DIR/0003-ollama-branding.hook.chroot" << 'EOF'
#!/bin/bash
set -e

echo "[HOOK 3/5] Installation Ollama + Branding..."

# Ollama
curl -fsSL https://ollama.ai/install.sh | sh
systemctl enable ollama || true

# Open WebUI
pip3 install open-webui --break-system-packages || true

# Branding OS
cat > /etc/os-release << 'EOS'
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
EOS

# MOTD
cat > /etc/motd << 'EMOTD'

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

EMOTD

echo "[OK] Ollama + Branding installés"
EOF

chmod +x "$HOOKS_DIR/0003-ollama-branding.hook.chroot"

# =============================================================================
# Hook 4: Metasploit Framework
# =============================================================================
cat > "$HOOKS_DIR/0004-metasploit.hook.chroot" << 'EOF'
#!/bin/bash
set -e

echo "[HOOK 4/5] Installation Metasploit..."

curl -fsSL https://apt.metasploit.com/metasploit-framework.gpg | \
    gpg --dearmor > /etc/apt/trusted.gpg.d/metasploit.gpg
echo "deb https://apt.metasploit.com/ buster main" > \
    /etc/apt/sources.list.d/metasploit.list

apt-get update
apt-get install -y metasploit-framework

echo "[OK] Metasploit installé"
EOF

chmod +x "$HOOKS_DIR/0004-metasploit.hook.chroot"

# =============================================================================
# Hook 5: Utilisateur teranga + Oh My Zsh
# =============================================================================
cat > "$HOOKS_DIR/0005-users-setup.hook.chroot" << 'EOF'
#!/bin/bash
set -e

echo "[HOOK 5/5] Configuration utilisateur..."

# Créer utilisateur
useradd -m -s /bin/zsh -G sudo,video,audio,input,netdev,plugdev,wireshark,ketreanga 2>/dev/null || true
echo "teranga:teranga" | chpasswd
passwd -d root

# Oh My Zsh
su - teranga -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Plugins
su - teranga -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions'
su - teranga -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'

# .zshrc
cat > /home/teranga/.zshrc << 'ZSHRC'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker)
source $ZSH/oh-my-zsh.sh
export LANG=fr_FR.UTF-8
export EDITOR=nano
alias ll='ls -la --color=auto'
alias update='sudo apt update && sudo apt upgrade -y'
alias ai='ollama run llama3.1'
alias docs='glow /etc/terangaos/docs/guide_fr.md'
echo "Bienvenue sur TérangaOS — Dalal ak diam"
ZSHRC

# Permissions et scripts
chmod +x /usr/local/bin/teranga-theme-engine
chmod +x /usr/local/bin/teranga-services
chmod +x /usr/local/bin/teranga-calendar
chmod +x /usr/local/bin/teranga-data-saver

# Lancement du thème au démarrage de la session
mkdir -p /home/teranga/.config/autostart
cat > /home/teranga/.config/autostart/teranga-theme.desktop << 'EAUTO'
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/teranga-theme-engine
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Teranga Theme Engine
EAUTO

chown -R teranga:teranga /home/teranga/.zshrc /home/teranga/.config/autostart

# Wayland session
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/hyprland.desktop << 'EWAY'
[Desktop Entry]
Name=Hyprland
Comment=TérangaOS — Hyprland Wayland Compositor
Exec=Hyprland
Type=Application
EWAY

echo "[OK] Utilisateur configuré"
EOF

chmod +x "$HOOKS_DIR/0005-users-setup.hook.chroot"

# =============================================================================
# Hook 6: Services Sénégal (Interface Simplifiée)
# =============================================================================
cat > "$HOOKS_DIR/0006-senegal-services.hook.chroot" << 'EOF'
#!/bin/bash
set -e

echo "[HOOK 6/6] Configuration des services Sénégal..."

# Créer le dossier des services sur le bureau
mkdir -p /home/teranga/Bureau/Services_Senegal
mkdir -p /usr/local/bin

# Script de lancement des services
cat > /usr/local/bin/teranga-services << 'ESRV'
#!/bin/bash
CHOIX=$(wofi --show dmenu --prompt "Choisissez un service sénégalais :" << 'ELIST'
1. Service Public (Gouv.sn)
2. Télédac (Urbanisme)
3. Senelec (Factures)
4. Sen'Eau (Eau)
5. Wave (Web Portal)
6. Portails Étudiants (ESP/UCAD)
7. Actualités (RTS/Soleil)
ELIST
)

case "$CHOIX" in
    *1*) xdg-open "https://www.service-public.gouv.sn" ;;
    *2*) xdg-open "https://www.teledac.sn" ;;
    *3*) xdg-open "https://www.senelec.sn" ;;
    *4*) xdg-open "https://www.seneau.sn" ;;
    *5*) xdg-open "https://www.wave.com" ;;
    *6*) xdg-open "https://esp.sn" ;;
    *7*) xdg-open "https://www.rts.sn" ;;
esac
ESRV

chmod +x /usr/local/bin/teranga-services

# Raccourci sur le bureau
cat > /home/teranga/Bureau/Services_Senegal/Teranga_Services.desktop << 'EDSK'
[Desktop Entry]
Name=Services Sénégal
Comment=Accès rapide aux services publics et locaux
Exec=/usr/local/bin/teranga-services
Icon=network-transmit-receive
Type=Application
Categories=Utility;
EDSK

# Permissions
chown -R teranga:teranga /home/teranga/Bureau

echo "[OK] Services Sénégal configurés"
EOF

chmod +x "$HOOKS_DIR/0006-senegal-services.hook.chroot"

# =============================================================================
# Hook 7: Optimisations de Performance (ZRAM, Sysctl, Scheduler)
# =============================================================================
cat > "$HOOKS_DIR/0007-performance-tuning.hook.chroot" << 'EOF'
#!/bin/bash
set -e

echo "[HOOK 7/7] Optimisation des performances système..."

# Installation de zram-tools
apt-get install -y zram-tools

# Configuration ZRAM (zstd)
cat > /etc/default/zramswap << 'EZRAM'
ALGO=zstd
PERCENT=50
PRIORITY=100
EZRAM

# Optimisation Sysctl
cat > /etc/sysctl.d/99-teranga-performance.conf << 'ESYS'
# Privilégier la RAM sur le Swap
vm.swappiness = 10
# Pression sur le cache VFS (fluidité explorer)
vm.vfs_cache_pressure = 50
# Réactivité du scheduler
kernel.sched_latency_ns = 10000000
kernel.sched_min_granularity_ns = 1000000
kernel.sched_wakeup_granularity_ns = 2000000
# Network stack tweaks
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
ESYS

# Activation des services d'optimisation
systemctl enable zramswap || true

echo "[OK] Optimisations de performance appliquées"
EOF

chmod +x "$HOOKS_DIR/0007-performance-tuning.hook.chroot"

echo "[OK] Tous les hooks (1-7) créés dans $HOOKS_DIR"
