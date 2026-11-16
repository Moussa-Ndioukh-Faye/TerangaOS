#!/bin/bash
# =============================================================================
# TérangaOS - Build Master Script
# Construit l'ISO complète depuis zéro
# =============================================================================

set -e

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TERANGA_DIR/build"
LOG_DIR="$BUILD_DIR/logs"

source "$BUILD_DIR/config.sh" 2>/dev/null || true

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   ██████╗ ████████╗ ██████╗██████╗  ██████╗                      ║"
echo "║   ██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██╔═══██╗                     ║"
echo "║   ██████╔╝   ██║   ██║     ██████╔╝██║   ██║                     ║"
echo "║   ██╔══██╗   ██║   ██║     ██╔══██╗██║   ██║                     ║"
echo "║   ██║  ██║   ██║   ╚██████╗██║  ██║╚██████╔╝                     ║"
echo "║   ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝                      ║"
echo "║                                                                      ║"
echo "║              Build System v1.0 | Codename: Djolof                    ║"
echo "║                                                                      ║"
echo "║         L'hospitalité numérique africaine                            ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# =============================================================================
# Configuration
# =============================================================================
PARALLEL_JOBS=$(nproc 2>/dev/null || echo 4)

# =============================================================================
# Fonctions utilitaires
# =============================================================================
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

log_error() {
    echo "[$(date '+%H:%M:%S')] [ERROR] $1" | tee -a "$LOG_DIR/error.log"
}

create_log_dir() {
    mkdir -p "$LOG_DIR"
}

# =============================================================================
# Étape 1: Préparation
# =============================================================================
step1_prepare() {
    log "═══════════════════════════════════════════════════"
    log "  ÉTAPE 1: PRÉPARATION"
    log "═══════════════════════════════════════════════════"
    
    log "Création des répertoires..."
    mkdir -p "$BUILD_DIR"/{toolchain,rootfs,images,sources,ccache,logs}
    
    log "Structure de base du rootfs..."
    bash "$TERANGA_DIR/build-rootfs.sh" base
    bash "$TERANGA_DIR/build-rootfs.sh" configure
    
    log "Étapes suivantes à exécuter manuellement sur Linux:"
    log "  - build-toolchain.sh headers"
    log "  - build-toolchain.sh gcc"
    log "  - build-toolchain.sh libc"
    log "  - build-kernel.sh all"
    log "  - build-rootfs.sh busybox"
    log "  - build-rootfs.sh coreutils"
    log "  - build-rootfs.sh bash"
    log "  - build-rootfs.sh openrc"
    log "  - build-rootfs.sh kernel"
    log "  - build-rootfs.sh initramfs"
    log "  - build-iso.sh all"
}

# =============================================================================
# Étape 2: Toolchain (Headers + GCC + glibc)
# =============================================================================
step2_toolchain() {
    log "═══════════════════════════════════════════════════"
    log "  ÉTAPE 2: TOOLCHAIN"
    log "═══════════════════════════════════════════════════"
    
    bash "$TERANGA_DIR/build-toolchain.sh" headers 2>&1 | tee "$LOG_DIR/01-headers.log"
    bash "$TERANGA_DIR/build-toolchain.sh" gcc 2>&1 | tee "$LOG_DIR/02-gcc.log"
    bash "$TERANGA_DIR/build-toolchain.sh" libc 2>&1 | tee "$LOG_DIR/03-glibc.log"
}

# =============================================================================
# Étape 3: Noyau Linux
# =============================================================================
step3_kernel() {
    log "═══════════════════════════════════════════════════"
    log "  ÉTAPE 3: NOYAU LINUX"
    log "═══════════════════════════════════════════════════"
    
    bash "$TERANGA_DIR/build-kernel.sh" all 2>&1 | tee "$LOG_DIR/04-kernel.log"
}

# =============================================================================
# Étape 4: RootFS
# =============================================================================
step4_rootfs() {
    log "═══════════════════════════════════════════════════"
    log "  ÉTAPE 4: ROOTFS"
    log "═══════════════════════════════════════════════════"
    
    bash "$TERANGA_DIR/build-rootfs.sh" busybox 2>&1 | tee "$LOG_DIR/05-busybox.log"
    bash "$TERANGA_DIR/build-rootfs.sh" coreutils 2>&1 | tee "$LOG_DIR/06-coreutils.log"
    bash "$TERANGA_DIR/build-rootfs.sh" bash 2>&1 | tee "$LOG_DIR/07-bash.log"
    bash "$TERANGA_DIR/build-rootfs.sh" openrc 2>&1 | tee "$LOG_DIR/08-openrc.log"
    bash "$TERANGA_DIR/build-rootfs.sh" kernel 2>&1 | tee "$LOG_DIR/09-kernel-modules.log"
    bash "$TERANGA_DIR/build-rootfs.sh" initramfs 2>&1 | tee "$LOG_DIR/10-initramfs.log"
}

# =============================================================================
# Étape 5: ISO
# =============================================================================
step5_iso() {
    log "═══════════════════════════════════════════════════"
    log "  ÉTAPE 5: ISO"
    log "═══════════════════════════════════════════════════"
    
    bash "$TERANGA_DIR/build-iso.sh" all 2>&1 | tee "$LOG_DIR/11-iso.log"
}

# =============================================================================
# Build complet
# =============================================================================
full_build() {
    log "DÉMARRAGE DU BUILD COMPLET"
    log "=========================="
    
    step1_prepare
    step2_toolchain
    step3_kernel
    step4_rootfs
    step5_iso
    
    log "═══════════════════════════════════════════════════"
    log "  BUILD TERMINÉ!"
    log "═══════════════════════════════════════════════════"
    log "  ISO: $TERANGA_DIR/terangaos-1.0-amd64.iso"
}

# =============================================================================
# Menu
# =============================================================================
show_menu() {
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║              MENU PRINCIPAL                     ║"
    echo "╠═══════════════════════════════════════════════════╣"
    echo "║  1) Préparation (structure + config)           ║"
    echo "║  2) Toolchain (headers + GCC + glibc)          ║"
    echo "║  3) Noyau Linux                                 ║"
    echo "║  4) RootFS (system packages)                  ║"
    echo "║  5) ISO                                         ║"
    echo "║  6) BUILD COMPLET (tout)                        ║"
    echo "║  7) Quitter                                     ║"
    echo "╚═══════════════════════════════════════════════════╝"
}

# =============================================================================
# Main
# =============================================================================
main() {
    create_log_dir
    
    if [ $# -gt 0 ]; then
        case "$1" in
            1|prepare) step1_prepare ;;
            2|toolchain) step2_toolchain ;;
            3|kernel) step3_kernel ;;
            4|rootfs) step4_rootfs ;;
            5|iso) step5_iso ;;
            all|full) full_build ;;
            help|--help|-h)
                echo "Usage: $0 [step|all]"
                echo ""
                echo "Steps:"
                echo "  1, prepare    - Préparation"
                echo "  2, toolchain  - Compilation toolchain"
                echo "  3, kernel     - Compilation noyau"
                echo "  4, rootfs     - Construction rootfs"
                echo "  5, iso        - Génération ISO"
                echo "  all, full     - Build complet"
                ;;
            *) echo "Option invalide. Utilisez: $0 help" ;;
        esac
        return
    fi
    
    show_menu
    read -p "Votre choix [1-7]: " choice
    
    case "$choice" in
        1) step1_prepare ;;
        2) step2_toolchain ;;
        3) step3_kernel ;;
        4) step4_rootfs ;;
        5) step5_iso ;;
        6) full_build ;;
        7) exit 0 ;;
        *) log_error "Choix invalide" ;;
    esac
}

main "$@"
