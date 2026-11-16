#!/bin/bash
# =============================================================================
# TérangaOS Build - Préparation de l'environnement
# Run on Linux or WSL2
# =============================================================================

set -e

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TERANGA_DIR/build"

echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║    TérangaOS - Préparation de l'environnement   ║"
echo "  ╚══════════════════════════════════════════════════╝"

# Vérifier si on est sur Linux
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "[WARN] Ce script est conçu pour Linux/WSL2"
    echo "[INFO] Sur Windows, utilisez WSL2: wsl --install"
fi

# =============================================================================
# Installation des dépendances (Debian/Ubuntu)
# =============================================================================
install_deps_debian() {
    echo "[INFO] Installation des dépendances Debian/Ubuntu..."
    sudo apt update
    sudo apt install -y \
        build-essential \
        git \
        wget \
        curl \
        rsync \
        cpio \
        zip \
        unzip \
        autoconf \
        automake \
        bison \
        flex \
        libtool \
        gawk \
        expat \
        libncurses-dev \
        libncursesw5-dev \
        zlib1g-dev \
        libssl-dev \
        libelf-dev \
        python3 \
        python3-pip \
        python3-venv \
        bc \
        kmod \
        cpio \
        libglib2.0-dev \
        libpixman-1-dev \
        libpng-dev \
        libjpeg-dev \
        libasound2-dev \
        libpulse-dev \
        libudev-dev \
        libxkbcommon-dev \
        libwayland-dev \
        libsoup2.4-dev \
        libdbus-1-dev \
        libgbm-dev \
        libxrandr-dev \
        libxcomposite-dev \
        libxdamage-dev \
        libxfixes-dev \
        libxrender-dev \
        libxi-dev \
        libxcursor-dev \
        meson \
        ninja-build \
        cmake \
        gperf \
        uuid-dev \
        libcap-dev \
        pkg-config
}

# =============================================================================
# Installation des dépendances (Fedora/RHEL)
# =============================================================================
install_deps_fedora() {
    echo "[INFO] Installation des dépendances Fedora/RHEL..."
    sudo dnf install \
        @development-tools \
        git \
        wget \
        curl \
        rsync \
        cpio \
        zip \
        unzip \
        autoconf \
        automake \
        bison \
        flex \
        libtool \
        gawk \
        expat \
        ncurses-devel \
        zlib-devel \
        openssl-devel \
        elfutils-libelf-devel \
        python3 \
        python3-pip \
        bc \
        kmod \
        glib2-devel \
        pixman-devel \
        libpng-devel \
        libjpeg-devel \
        alsa-lib-devel \
        pulseaudio-libs-devel \
        libudev-devel \
        wayland-devel \
        dbus-devel \
        gbm-devel \
        libXrandr-devel \
        mesa-libgbm-devel \
        meson \
        ninja-build \
        cmake \
        gperf \
        uuid-devel \
        libcap-devel
}

# =============================================================================
# Initialisation des sous-modules git
# =============================================================================
init_git_submodules() {
    echo "[INFO] Initialisation des sous-modules git..."
    
    cd "$TERANGA_DIR/linux-master/linux-master"
    git submodule update --init --recursive || true
    
    cd "$TERANGA_DIR/gcc-master/gcc-master"
    git submodule update --init --recursive || true
    
    cd "$TERANGA_DIR"
}

# =============================================================================
# Configuration de l'outil de build
# =============================================================================
setup_build_dir() {
    echo "[INFO] Configuration du répertoire de build..."
    mkdir -p "$BUILD_DIR"/{toolchain,rootfs,images,sources,ccache}
    
    cat > "$BUILD_DIR/config.sh" << 'EOFCONFIG'
# TérangaOS Build Configuration
export TERANGA_VERSION="1.0"
export TERANGA_CODENAME="Djolof"
export ARCH="x86_64"
export CROSS_COMPILE="x86_64-linux-gnu-"
export INSTALL_MOD_PATH="$BUILD_DIR/rootfs"
export INSTALL_PATH="$BUILD_DIR/rootfs/boot"
export INSTALL_HDR_PATH="$BUILD_DIR/rootfs/usr"
EOFCONFIG
}

# =============================================================================
# Détection de la distribution
# =============================================================================
detect_distro() {
    if [ -f /etc/debian_version ]; then
        install_deps_debian
    elif [ -f /etc/fedora-release ]; then
        install_deps_fedora
    else
        echo "[WARN] Distribution non détectée. Installez les dépendances manuellement."
    fi
}

# =============================================================================
# Menu
# =============================================================================
show_menu() {
    echo ""
    echo "1) Installer les dépendances"
    echo "2) Initialiser les sous-modules git"
    echo "3) Configurer le build"
    echo "4) Tout faire"
    echo "5) Quitter"
}

# =============================================================================
# Main
# =============================================================================
main() {
    if [ $# -gt 0 ]; then
        case "$1" in
            deps) detect_distro ;;
            submodules) init_git_submodules ;;
            setup) setup_build_dir ;;
            all)
                detect_distro
                init_git_submodules
                setup_build_dir
                ;;
            *) echo "Usage: $0 {deps|submodules|setup|all}" ;;
        esac
        return
    fi

    show_menu
    read -p "Choix [1-5]: " choice
    
    case "$choice" in
        1) detect_distro ;;
        2) init_git_submodules ;;
        3) setup_build_dir ;;
        4)
            detect_distro
            init_git_submodules
            setup_build_dir
            echo "[OK] Environment prêt!"
            ;;
        5) exit 0 ;;
    esac
}

main "$@"
