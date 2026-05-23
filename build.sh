#!/bin/bash
# =============================================================================
# TérangaOS - Build Principal Complet
# Basé sur terangaos_complete.html
# =============================================================================

set -e

if mountpoint -q /mnt/c 2>/dev/null; then
    WORK_DIR="/tmp/teranga-build"
    echo "Building in WSL local directory: $WORK_DIR"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    cp -r /mnt/c/Users/mouss/OneDrive/Desktop/TerangaOS/* "$WORK_DIR/" 2>/dev/null || true
fi

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$TERANGA_DIR/build.log"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   ████████╗███████╗██████╗  █████╗ ███╗  ██╗ ██████╗  █████╗ ║"
echo "║   ╚══██╔══╝██╔════╝██╔══██╗██╔══██╗████╗ ██║██╔════╝ ██╔══██╗║"
echo "║      ██║   █████╗  ██████╔╝███████║██╔██╗██║██║ ████╗███████║║"
echo "║      ██║   ██╔══╝  ██╔══██╗██╔══██║██║╚████║██║   ██║██╔══██║║"
echo "║      ██║   ███████╗██║  ██║██║  ██║██║ ╚███║╚██████╔╝██║  ██║║"
echo "║      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚══╝ ╚═════╝ ╚═╝  ╚═╝║"
echo "║                                                              ║"
echo "║              Build System v1.0 | Codename: Djolof            ║"
echo "║         L'hospitalité numérique africaine                     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# =============================================================================
# Fonctions
# =============================================================================
log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_deps() {
    log "Vérification des dépendances..."
    local deps=("lb" "debootstrap" "git" "curl" "wget" "cmake" "ninja")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log "ERREUR: Dépendances manquantes: ${missing[*]}"
        log "Installez-les avec: sudo apt install ${missing[*]}"
        exit 1
    fi
    log "OK: Toutes les dépendances présentes"
}

prepare_dirs() {
    log "Préparation des répertoires..."
    mkdir -p live-build-config/config/package-lists live-build-config/config/hooks/live live-build-config/config/includes.chroot/etc
    mkdir -p live-build-config/config/includes.chroot/etc/sddm.conf.d
    mkdir -p live-build-config/config/includes.chroot/home/teranga/.config/{hypr,waybar,kitty,wofi,mako}
    mkdir -p live-build-config/config/includes.chroot/usr/share/backgrounds/terangaos
    mkdir -p live-build-config/config/includes.chroot/usr/share/grub/themes/terangaos
    mkdir -p live-build-config/config/includes.chroot/usr/share/icons/terangaos
    log "OK: Répertoires créés"
}

create_package_lists() {
    log "Vérification des package lists..."
    
    if [ ! -f config/package-lists/base.list.chroot ]; then
        log "Copie des package lists vers live-build-config..."
        cp -r config/package-lists/* live-build-config/config/package-lists/
    fi
    
    log "OK: Package lists prêtes"
}

create_configs() {
    log "Vérification des configurations..."
    
    if [ -d config/includes.chroot/etc ]; then
        log "Copie des configurations vers live-build-config..."
        cp -r config/includes.chroot/* live-build-config/config/includes.chroot/
        log "OK: Configurations copiées dans live-build-config/"
    fi
    
    log "OK: Configurations prêtes"
}

create_hooks() {
    log "Création des hooks..."
    bash scripts/write-hooks.sh
    if [ -d scripts/config/hooks/live ]; then
        cp -r scripts/config/hooks/live/* live-build-config/config/hooks/live/
    fi
    log "OK: Hooks copiés vers live-build-config"
}

configure_live_build() {
    log "Configuration de live-build..."
    
    lb config \
        --distribution trixie \
        --architecture amd64 \
        --binary-images iso-hybrid \
        --debian-installer live \
        --apt-recommends false \
        --linux-packages "linux-image linux-headers" \
        --bootappend-live "boot=live components locales=fr_FR.UTF-8 keyboard-layouts=fr" \
        --iso-volume "TerangaOS-1.0-Djolof" \
        --iso-publisher "ESP-UCAD-Dakar-TerangaOS-Project" \
        --verbose \
        2>&1 | tee -a "$LOG_FILE"
    
    log "OK: live-build configuré"
}

build_iso() {
    log "DÉMARRAGE DU BUILD (30-90 minutes)..."
    log "Voir le progrès dans: $LOG_FILE"
    log ""
    
    if ! sudo lb build --verbose 2>&1 | tee -a "$LOG_FILE"; then
        log "ERREUR: Le build a échoué."
        log "=== Dernières lignes du log ==="
        tail -n 50 "$LOG_FILE"
        exit 1
    fi
}

finalize() {
    ISO_FILE=$(ls *.iso 2>/dev/null | head -1)
    if [ -n "$ISO_FILE" ]; then
        mv "$ISO_FILE" "terangaos-1.0-amd64.iso"
        sha256sum terangaos-1.0-amd64.iso > terangaos-1.0.sha256
        log ""
        log "╔══════════════════════════════════════════════════╗"
        log "║  ✅ BUILD TERMINÉ AVEC SUCCÈS!                 ║"
        log "╚══════════════════════════════════════════════════╝"
        log ""
        log "  Fichier: terangaos-1.0-amd64.iso"
        log "  Taille:  $(du -h terangaos-1.0-amd64.iso | cut -f1)"
        log "  SHA256:   $(head -c 32 terangaos-1.0.sha256)..."
        log ""
        log "  'Dalal ak diam' — TérangaOS est prêt! 🌍"
    else
        log "ERREUR: ISO non trouvée. Voir $LOG_FILE"
        exit 1
    fi
}

# =============================================================================
# Menu
# =============================================================================
show_help() {
    echo ""
    echo "Usage: $0 [commande]"
    echo ""
    echo "Commandes:"
    echo "  deps       - Vérifier les dépendances"
    echo "  prepare    - Préparer les répertoires"
    echo "  packages   - Créer les package lists"
    echo "  configs    - Créer les configurations"
    echo "  hooks      - Créer les hooks"
    echo "  configure  - Configurer live-build"
    echo "  build      - Lancer le build"
    echo "  all        - Build complet (défaut)"
    echo "  help       - Cette aide"
    echo ""
}

# =============================================================================
# Main
# =============================================================================
main() {
    case "${1:-all}" in
        deps)       check_deps ;;
        prepare)    prepare_dirs ;;
        packages)   create_package_lists ;;
        configs)    create_configs ;;
        hooks)      create_hooks ;;
        configure)  configure_live_build ;;
        build)      build_iso ;;
        all)
            check_deps
            prepare_dirs
            create_package_lists
            create_configs
            create_hooks
            configure_live_build
            build_iso
            finalize
            ;;
        help|--help|-h) show_help ;;
        *)  echo "Commande inconnue: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
