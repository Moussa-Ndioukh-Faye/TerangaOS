#!/bin/bash
# TérangaOS — Script de nettoyage complet
set -e

echo "[TERANGA] Nettoyage en cours..."

# Nettoyage live-build
if [ -d "live-build-config" ]; then
    cd live-build-config
    sudo lb clean --purge
    cd ..
fi

# Nettoyage des fichiers ISO et logs
rm -f *.iso *.sha256 *.log
rm -f wget-log*

# Nettoyage des répertoires de build manuels
rm -rf build/
rm -rf chroot/
rm -rf binary/

echo "[TERANGA] ✓ Nettoyage terminé. Prêt pour un build propre."
