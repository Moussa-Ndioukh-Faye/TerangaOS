#!/bin/bash
# =============================================================================
# TérangaOS - Nettoyer et reconfigurer live-build
# =============================================================================

set -e

cd "$(dirname "$0")"

echo "[TERANGOS] Nettoyage du build..."
sudo lb clean --all

echo "[TERANGOS] Suppression du cache..."
rm -rf .build

echo "[TERANGOS] Reconfiguration..."
sudo lb config --distribution bookworm --architectures amd64

echo "[OK] Prêt pour le build!"
echo ""
echo "Pour builder, executez:"
echo "  sudo lb build"