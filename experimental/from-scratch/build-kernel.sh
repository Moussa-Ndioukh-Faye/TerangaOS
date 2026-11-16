#!/bin/bash
# =============================================================================
# TérangaOS - Compilation du Noyau Linux
# =============================================================================

set -e

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TERANGA_DIR/build"
LINUX_SRC="$TERANGA_DIR/linux-master/linux-master"

source "$BUILD_DIR/config.sh" 2>/dev/null || true

echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         TérangaOS - Compilation du Noyau        ║"
echo "  ╚══════════════════════════════════════════════════╝"

# =============================================================================
# Configuration du noyau
# =============================================================================
configure_kernel() {
    echo "[INFO] Configuration du noyau pour TérangaOS..."
    
    cd "$LINUX_SRC"
    
    # Configuration de base
    make ARCH="$ARCH" \
         CROSS_COMPILE="$CROSS_COMPILE" \
         x86_64_defconfig
    
    # Personnalisation pour TérangaOS
    scripts/config --set-str LOCALVERSION "-terangaos"
    scripts/config --set-str DEFAULT_HOSTNAME "terangaos"
    scripts/config --set-str CONSOLE_LOGLEVEL_DEFAULT "3"
    
    # Optimisation de la performance
    scripts/config --enable CONFIG_PREEMPT
    scripts/config --enable CONFIG_PREEMPT_VOLUNTARY
    scripts/config --set-val CONFIG_HZ 1000
    scripts/config --enable CONFIG_HZ_1000
    scripts/config --disable CONFIG_HZ_250
    scripts/config --enable CONFIG_SCHED_AUTOGROUP
    scripts/config --enable CONFIG_SCSI_MQ_DEFAULT
    scripts/config --enable CONFIG_MQ_IOSCHED_DEADLINE
    
    # ZRAM et Compression
    scripts/config --enable CONFIG_ZRAM
    scripts/config --enable CONFIG_ZRAM_DEF_COMP_ZSTD
    scripts/config --enable CONFIG_CRYPTO_ZSTD
    scripts/config --enable CONFIG_ZSMALLOC
    scripts/config --enable CONFIG_ZSMALLOC_STAT
    
    # Réduction de la taille et de l'usage mémoire
    scripts/config --disable CONFIG_DEBUG_INFO
    scripts/config --disable CONFIG_DEBUG_KERNEL
    scripts/config --enable CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE
    
    # Amélioration de la réactivité (Tuning IO)
    scripts/config --enable CONFIG_IOSCHED_BFQ
    scripts/config --enable CONFIG_BFQ_GROUP_IOSCHED
    
    # Support ext4
    scripts/config --enable CONFIG_EXT4_FS
    scripts/config --enable CONFIG_EXT4_FS_POSIX_ACL
    scripts/config --enable CONFIG_EXT4_FS_SECURITY
    
    # Support réseau
    scripts/config --enable CONFIG_NET
    scripts/config --enable CONFIG_INET
    scripts/config --enable CONFIG_NET_ETHERNET
    
    # Support virtualization
    scripts/config --enable CONFIG_VIRTIO
    scripts/config --enable CONFIG_VIRTIO_PCI
    scripts/config --enable CONFIG_VIRTIO_BALLOON
    scripts/config --enable CONFIG_VIRTIO_BLK
    scripts/config --enable CONFIG_VIRTIO_NET
    
    # Support initrd/initramfs
    scripts/config --enable CONFIG_BLK_DEV_INITRD
    scripts/config --enable CONFIG_INITRAMFS_SOURCE
    
    # Support Live Boot
    scripts/config --enable CONFIG_OVERLAY_FS
    scripts/config --enable CONFIG_SQUASHFS
    
    echo "[OK] Configuration appliquée"
}

# =============================================================================
# Compilation du noyau
# =============================================================================
compile_kernel() {
    echo "[INFO] Compilation du noyau (cela peut prendre longtemps)..."
    
    cd "$LINUX_SRC"
    
    # Compiler avec tous les CPU
    make ARCH="$ARCH" \
         CROSS_COMPILE="$CROSS_COMPILE" \
         -j$(nproc) \
         bzImage
    
    echo "[OK] Noyau compilé"
}

# =============================================================================
# Installation du noyau
# =============================================================================
install_kernel() {
    echo "[INFO] Installation du noyau..."
    
    cd "$LINUX_SRC"
    
    # Installer les modules
    make ARCH="$ARCH" \
         CROSS_COMPILE="$CROSS_COMPILE" \
         INSTALL_MOD_PATH="$BUILD_DIR/rootfs" \
         modules_install
    
    # Installer les headers
    make ARCH="$ARCH" \
         CROSS_COMPILE="$CROSS_COMPILE" \
         INSTALL_HDR_PATH="$BUILD_DIR/rootfs/usr" \
         headers_install
    
    # Copier le noyau
    mkdir -p "$BUILD_DIR/rootfs/boot"
    cp arch/x86/boot/bzImage "$BUILD_DIR/rootfs/boot/vmlinuz-terangaos"
    cp System.map "$BUILD_DIR/rootfs/boot/System.map-terangaos"
    cp .config "$BUILD_DIR/rootfs/boot/config-terangaos"
    
    echo "[OK] Noyau installé dans $BUILD_DIR/rootfs/boot"
}

# =============================================================================
# Menu
# =============================================================================
main() {
    case "$1" in
        config) configure_kernel ;;
        compile) compile_kernel ;;
        install) install_kernel ;;
        all)
            configure_kernel
            compile_kernel
            install_kernel
            ;;
        menuconfig)
            cd "$LINUX_SRC"
            make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" menuconfig
            ;;
        *) 
            echo "Usage: $0 {config|compile|install|all|menuconfig}"
            echo ""
            echo "Étapes:"
            echo "  1. config     - Configurer le noyau"
            echo "  2. compile   - Compiler le noyau"
            echo "  3. install   - Installer le noyau"
            echo "  4. all       - Tout faire"
            echo "  5. menuconfig - Interface de configuration"
            ;;
    esac
}

main "$@"
