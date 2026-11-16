#!/bin/bash
# =============================================================================
# TérangaOS — construction de l'ISO live avec live-build
#
# Usage : sudo ./build.sh [commande] [--variant core|cyber|full]
#
# À lancer sur Debian 13 (trixie). Sur Ubuntu ou ailleurs, utilisez
# ./build-docker.sh, qui lance ce script dans un conteneur Debian.
# =============================================================================
set -euo pipefail

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$TERANGA_DIR"

# --- Paramètres (modifiables par variables d'environnement) ------------------
VARIANT="${VARIANT:-full}"
SUITE="${SUITE:-trixie}"
MIRROR="${MIRROR:-http://deb.debian.org/debian/}"
SECURITY_MIRROR="${SECURITY_MIRROR:-http://security.debian.org/debian-security/}"
VERSION="1.0"
CODENAME="Djolof"

# Paquets sans lesquels l'ISO n'a pas de sens : le build s'arrête s'ils
# n'existent pas dans la version de Debian ciblée.
REQUIRED_PACKAGES="live-boot live-config gnome-core gdm3 calamares"

BUILD_ROOT="$TERANGA_DIR/build"
LOG_FILE=""
WORK_DIR=""

# =============================================================================
# Utilitaires
# =============================================================================
log()  { echo "[$(date '+%H:%M:%S')] $*" | tee -a "${LOG_FILE:-/dev/null}"; }
warn() { log "ATTENTION : $*"; }
die()  { log "ERREUR : $*"; exit 1; }

set_paths() {
    WORK_DIR="$BUILD_ROOT/$VARIANT"
    LOG_FILE="$BUILD_ROOT/build-$VARIANT.log"
    mkdir -p "$BUILD_ROOT"
}

banner() {
    cat <<'EOF'

  ████████╗███████╗██████╗  █████╗ ███╗   ██╗ ██████╗  █████╗
  ╚══██╔══╝██╔════╝██╔══██╗██╔══██╗████╗  ██║██╔════╝ ██╔══██╗
     ██║   █████╗  ██████╔╝███████║██╔██╗ ██║██║  ███╗███████║
     ██║   ██╔══╝  ██╔══██╗██╔══██║██║╚██╗██║██║   ██║██╔══██║
     ██║   ███████╗██║  ██║██║  ██║██║ ╚████║╚██████╔╝██║  ██║
     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
        Build System v1.0 · Codename Djolof · ESP/UCAD Dakar

EOF
}

# =============================================================================
# Vérifications
# =============================================================================
check_root() {
    [ "$(id -u)" -eq 0 ] || die "lancez le build avec sudo (live-build a besoin des droits root)."
}

check_variant() {
    case "$VARIANT" in
        core|cyber|full) ;;
        *) die "variante inconnue : '$VARIANT' (choix : core, cyber, full)" ;;
    esac
}

check_host() {
    log "Vérification de la machine hôte..."

    # live-build d'Ubuntu (3.0~a57) ne sait pas construire une Debian récente
    local host_id="" host_codename=""
    if [ -r /etc/os-release ]; then
        host_id=$(. /etc/os-release && echo "${ID:-}")
        host_codename=$(. /etc/os-release && echo "${VERSION_CODENAME:-}")
    fi
    if [ "$host_id" != "debian" ]; then
        die "hôte '$host_id' : construisez avec ./build-docker.sh (conteneur Debian $SUITE)."
    fi
    if [ "$host_codename" != "$SUITE" ]; then
        warn "hôte Debian '$host_codename' et cible '$SUITE' : la vérification des paquets est désactivée."
    fi

    # Les systèmes de fichiers Windows/réseau cassent debootstrap (« tar failed »)
    local fstype
    fstype=$(stat -f -c %T "$TERANGA_DIR")
    case "$fstype" in
        ntfs*|fuseblk|msdos|vfat|exfat|9p|v9fs|drvfs|smb*|cifs|vboxsf|nfs*)
            die "le projet est sur un système de fichiers '$fstype'. Clonez-le dans votre dossier Linux (ext4), par exemple ~/TerangaOS." ;;
    esac

    local missing=()
    for cmd in lb debootstrap xorriso mksquashfs; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [ ${#missing[@]} -ne 0 ]; then
        die "outils manquants : ${missing[*]}
  Installez-les : sudo apt install live-build debootstrap xorriso squashfs-tools isolinux syslinux-common grub-efi-amd64-bin grub-pc-bin mtools dosfstools"
    fi

    local free_gb
    free_gb=$(df -P -BG "$TERANGA_DIR" | awk 'NR==2 {gsub("G","",$4); print $4}')
    if [ "${free_gb:-0}" -lt 25 ]; then
        warn "seulement ${free_gb} Go libres. Prévoir 20 Go (core) à 40 Go (full)."
    fi
    log "OK : hôte compatible"
}

# =============================================================================
# Préparation de la configuration live-build
# =============================================================================
package_lists_for_variant() {
    echo base desktop live installer dev
    case "$VARIANT" in
        cyber) echo cybersec ;;
        full)  echo cybersec ai ;;
    esac
}

hook_dirs_for_variant() {
    echo common
    case "$VARIANT" in
        cyber) echo cyber ;;
        full)  echo cyber full ;;
    esac
}

# Indique si un paquet est installable dans la suite ciblée (via l'APT de
# l'hôte, qui doit être sur la même version de Debian).
package_available() {
    local policy
    policy=$(LC_ALL=C apt-cache policy "$1" 2>/dev/null) || return 1
    [[ "$policy" =~ Candidate:\ [^\(] ]]
}

can_check_packages() {
    [ "$(. /etc/os-release && echo "${VERSION_CODENAME:-}")" = "$SUITE" ] \
        && [ "${SKIP_PACKAGE_CHECK:-0}" != 1 ]
}

stage_package_lists() {
    log "Listes de paquets (variante $VARIANT)..."
    local dest="$WORK_DIR/config/package-lists"
    rm -rf "$dest"
    mkdir -p "$dest"

    local check=0 missing=() list pkg
    if can_check_packages; then
        check=1
        LC_ALL=C apt-get update -qq || warn "apt-get update a échoué : vérification moins fiable"
    fi

    for list in $(package_lists_for_variant); do
        local src="config/package-lists/$list.list.chroot"
        [ -f "$src" ] || die "liste introuvable : $src"
        : > "$dest/$list.list.chroot"
        for pkg in $(sed -e 's/#.*//' "$src"); do
            if [ "$check" -eq 1 ] && ! package_available "$pkg"; then
                missing+=("$pkg")
                continue
            fi
            echo "$pkg" >> "$dest/$list.list.chroot"
        done
    done

    if [ ${#missing[@]} -ne 0 ]; then
        warn "paquets absents de Debian $SUITE, ignorés : ${missing[*]}"
        for pkg in $REQUIRED_PACKAGES; do
            for m in "${missing[@]}"; do
                [ "$pkg" = "$m" ] && die "paquet indispensable absent : $pkg"
            done
        done
    fi
    log "OK : $(cat "$dest"/*.list.chroot | wc -l) paquets"
}

stage_includes_and_hooks() {
    log "Fichiers et hooks..."
    local inc="$WORK_DIR/config/includes.chroot"
    local hooks="$WORK_DIR/config/hooks/live"
    rm -rf "$inc" "$hooks"
    mkdir -p "$inc" "$hooks"

    cp -a config/includes.chroot/. "$inc/"
    mkdir -p "$inc/etc/terangaos"
    echo "$VARIANT" > "$inc/etc/terangaos/variant"

    local dir hook
    for dir in $(hook_dirs_for_variant); do
        for hook in config/hooks/"$dir"/*.hook.chroot; do
            [ -e "$hook" ] || continue
            install -m 0755 "$hook" "$hooks/"
        done
    done
    log "OK : $(ls "$hooks" | wc -l) hooks ($(hook_dirs_for_variant | xargs))"
}

configure_live_build() {
    log "Configuration de live-build ($SUITE, amd64)..."
    mkdir -p "$WORK_DIR"
    (
        cd "$WORK_DIR"
        # Repart d'une configuration propre en gardant le cache des paquets
        lb clean --all >/dev/null 2>&1 || true
        rm -rf config/binary config/bootstrap config/chroot config/common config/source

        lb config \
            --mode debian \
            --distribution "$SUITE" \
            --architecture amd64 \
            --archive-areas "main contrib non-free non-free-firmware" \
            --mirror-bootstrap "$MIRROR" \
            --mirror-chroot "$MIRROR" \
            --mirror-binary "$MIRROR" \
            --mirror-chroot-security "$SECURITY_MIRROR" \
            --mirror-binary-security "$SECURITY_MIRROR" \
            --security true \
            --updates true \
            --binary-images iso-hybrid \
            --debian-installer none \
            --apt-recommends false \
            --firmware-chroot true \
            --firmware-binary true \
            --linux-packages "linux-image linux-headers" \
            --bootappend-live "boot=live components quiet splash locales=fr_FR.UTF-8 keyboard-layouts=fr timezone=Africa/Dakar" \
            --iso-application "TerangaOS" \
            --iso-publisher "ESP-UCAD-Dakar-TerangaOS-Project" \
            --iso-volume "TERANGAOS_${VARIANT^^}" \
            --image-name "terangaos-$VERSION-$VARIANT" \
            --cache true \
            --cache-packages true
    ) 2>&1 | tee -a "$LOG_FILE"
    log "OK : live-build configuré"
}

prepare() {
    check_variant
    set_paths
    mkdir -p "$WORK_DIR"
    configure_live_build
    stage_package_lists
    stage_includes_and_hooks
}

# =============================================================================
# Construction
# =============================================================================
build_iso() {
    log "Construction de l'ISO $VARIANT (30 à 120 minutes selon la variante et la connexion)..."
    log "Journal complet : $LOG_FILE"
    if ! (cd "$WORK_DIR" && lb build) 2>&1 | tee -a "$LOG_FILE"; then
        log "=== 40 dernières lignes du journal ==="
        tail -n 40 "$LOG_FILE"
        die "le build a échoué."
    fi
}

finalize() {
    local iso
    iso=$(find "$WORK_DIR" -maxdepth 1 -name '*.iso' -print -quit)
    [ -n "$iso" ] || die "aucune ISO produite, voir $LOG_FILE"

    local final="$BUILD_ROOT/terangaos-$VERSION-$VARIANT-amd64.iso"
    mv -f "$iso" "$final"
    (cd "$BUILD_ROOT" && sha256sum "$(basename "$final")" > "$(basename "$final").sha256")

    if [ -n "${GPG_KEY:-}" ] && command -v gpg >/dev/null 2>&1; then
        gpg --batch --yes --local-user "$GPG_KEY" --armor --detach-sign "$final" \
            && log "OK : signature GPG $(basename "$final").asc"
    fi

    # Rend les fichiers à l'utilisateur qui a lancé sudo
    if [ -n "${HOST_UID:-${SUDO_UID:-}}" ]; then
        chown "${HOST_UID:-$SUDO_UID}:${HOST_GID:-${SUDO_GID:-$SUDO_UID}}" \
            "$BUILD_ROOT" "$final"* "$LOG_FILE" 2>/dev/null || true
    fi

    log ""
    log "✅ BUILD TERMINÉ — TérangaOS $VERSION ($CODENAME), variante $VARIANT"
    log "   ISO    : $final ($(du -h "$final" | cut -f1))"
    log "   SHA256 : $final.sha256"
    log "   « Dalal ak diam » 🌍"
}

clean() {
    check_variant
    set_paths
    if [ -d "$WORK_DIR" ]; then
        (cd "$WORK_DIR" && lb clean --purge) || true
        rm -rf "$WORK_DIR"
    fi
    log "OK : $WORK_DIR supprimé"
}

# =============================================================================
# Point d'entrée
# =============================================================================
show_help() {
    cat <<EOF
Usage : sudo $0 [commande] [--variant core|cyber|full]

Commandes :
  all        Build complet (défaut)
  check      Vérifier la machine hôte
  prepare    Préparer la configuration live-build sans construire
  build      Construire à partir d'une configuration déjà préparée
  clean      Supprimer le dossier de build de la variante
  help       Afficher cette aide

Options :
  --variant  core  : GNOME 48 + outils de développement      (~3 Go)
             cyber : core + cybersécurité, Metasploit          (~4 Go)
             full  : cyber + IA (Ollama, PyTorch CPU, Jupyter) (~7 Go)  [défaut]

Variables : SUITE (trixie), MIRROR, SECURITY_MIRROR, GPG_KEY, SKIP_PACKAGE_CHECK=1

Sur Ubuntu : ./build-docker.sh --variant core
EOF
}

main() {
    local cmd="all"
    while [ $# -gt 0 ]; do
        case "$1" in
            --variant)   [ $# -ge 2 ] || die "--variant demande une valeur"; VARIANT="$2"; shift 2 ;;
            --variant=*) VARIANT="${1#*=}"; shift ;;
            help|-h|--help) show_help; exit 0 ;;
            *) cmd="$1"; shift ;;
        esac
    done

    case "$cmd" in
        all)
            banner; check_root; check_variant; set_paths
            : > "$LOG_FILE"
            check_host; prepare; build_iso; finalize ;;
        check)   check_variant; set_paths; check_host ;;
        prepare) check_root; prepare ;;
        build)   check_root; check_variant; set_paths; build_iso; finalize ;;
        clean)   check_root; clean ;;
        *) show_help; die "commande inconnue : $cmd" ;;
    esac
}

main "$@"
