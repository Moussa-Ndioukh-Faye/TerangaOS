#!/bin/bash
# ═══════════════════════════════════════════════════════
# TérangaOS — Script de préparation WSL2
# À exécuter UNE SEULE FOIS dans WSL2 Debian
# ═══════════════════════════════════════════════════════
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; GOLD='\033[0;33m'; NC='\033[0m'

echo -e "${GOLD}"
echo "  TérangaOS — Préparation de l'environnement de build (WSL2)"
echo -e "${NC}"

# ── Vérification WSL ──
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  echo -e "${RED}[WARN]${NC} Ce script est optimisé pour WSL2."
  echo -e "       Il peut quand même fonctionner sur une vraie machine Debian."
  read -p "Continuer ? (o/n): " ans
  [[ "$ans" != "o" ]] && exit 0
fi

echo -e "${GOLD}[1/4]${NC} Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo -e "${GOLD}[2/4]${NC} Installation des outils de build..."
sudo apt install -y \
  live-build \
  debootstrap \
  git \
  curl \
  wget \
  build-essential \
  cmake \
  ninja-build \
  pkg-config \
  meson \
  squashfs-tools \
  xorriso \
  isolinux \
  librsvg2-bin \
  imagemagick \
  libwayland-dev \
  libxkbcommon-dev \
  libxkbcommon-x11-dev \
  libegl1-mesa-dev \
  libgles2-mesa-dev \
  libdrm-dev \
  libgbm-dev \
  libseat-dev \
  libinput-dev \
  libudev-dev \
  libsystemd-dev \
  libpixman-1-dev \
  libvulkan-dev \
  glslang-dev \
  libpango1.0-dev \
  libcairo2-dev \
  librsvg2-dev \
  libtomlplusplus-dev \
  libdisplay-info-dev \
  hwdata \
  python3 \
  python3-pip

echo -e "${GOLD}[3/4]${NC} Vérification des outils..."
TOOLS=(lb debootstrap git curl cmake ninja-build meson)
ALL_OK=true
for t in "${TOOLS[@]}"; do
  if command -v "$t" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $t"
  else
    echo -e "  ${RED}✗${NC} $t manquant"
    ALL_OK=false
  fi
done

echo -e "${GOLD}[4/4]${NC} Configuration WSL2..."
# Augmenter la mémoire WSL2 si fichier .wslconfig accessible
WSLCONFIG="/mnt/c/Users/$USER/.wslconfig"
if [ ! -f "$WSLCONFIG" ]; then
  cat > "$WSLCONFIG" << 'WSLCFG'
[wsl2]
memory=8GB
processors=4
swap=4GB
localhostForwarding=true
WSLCFG
  echo -e "  ${GREEN}✓${NC} .wslconfig créé (8GB RAM, 4 CPU)"
fi

echo ""
if $ALL_OK; then
  echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✅ Environnement de build prêt !             ║${NC}"
  echo -e "${GREEN}║  Prochaine étape :                            ║${NC}"
  echo -e "${GREEN}║  cd terangaos && sudo bash build.sh           ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
else
  echo -e "${RED}[WARN]${NC} Certains outils manquent. Relancer le script."
fi
