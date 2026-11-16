#!/bin/bash
# =============================================================================
# TérangaOS — construction depuis Ubuntu (ou toute machine Linux avec Docker)
#
# Le live-build fourni par Ubuntu est trop ancien pour construire une Debian
# récente. Ce script lance donc build.sh dans un conteneur Debian officiel.
#
# Usage : ./build-docker.sh [--variant core|cyber|full] [commande build.sh]
# =============================================================================
set -euo pipefail

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE="${SUITE:-trixie}"
IMAGE="debian:$SUITE"

die() { echo "ERREUR : $*" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || die "Docker n'est pas installé.
  Sur Ubuntu : sudo apt install docker.io && sudo usermod -aG docker \$USER  (puis reconnectez-vous)"

DOCKER=(docker)
if ! docker info >/dev/null 2>&1; then
    if sudo docker info >/dev/null 2>&1; then
        DOCKER=(sudo docker)
    else
        die "impossible de joindre le démon Docker (sudo systemctl start docker ?)"
    fi
fi

# Les partitions Windows (NTFS) montées sous Ubuntu cassent le build
case "$(stat -f -c %T "$TERANGA_DIR")" in
    ntfs*|fuseblk|msdos|vfat|exfat)
        die "le projet est sur une partition Windows. Clonez-le dans votre dossier personnel Ubuntu :
  cd ~ && git clone https://github.com/Moussa-Ndioukh-Faye/TerangaOS.git" ;;
esac

echo "[TERANGA] Conteneur $IMAGE — build.sh $*"

"${DOCKER[@]}" run --rm --privileged \
    -v "$TERANGA_DIR":/terangaos \
    -w /terangaos \
    -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
    -e SUITE="$SUITE" \
    -e MIRROR="${MIRROR:-http://deb.debian.org/debian/}" \
    -e VARIANT="${VARIANT:-full}" \
    "$IMAGE" bash -euo pipefail -c '
        # Active contrib / non-free pour que la vérification des paquets
        # voie les mêmes dépôts que l ISO
        if [ -f /etc/apt/sources.list.d/debian.sources ]; then
            sed -i "s/^Components: main$/Components: main contrib non-free non-free-firmware/" \
                /etc/apt/sources.list.d/debian.sources
        fi
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq
        apt-get install -y -qq --no-install-recommends \
            live-build debootstrap xorriso squashfs-tools isolinux syslinux-common \
            grub-efi-amd64-bin grub-pc-bin mtools dosfstools \
            ca-certificates curl gnupg git rsync cpio file >/dev/null
        ./build.sh "$@"
    ' build-docker "$@"
