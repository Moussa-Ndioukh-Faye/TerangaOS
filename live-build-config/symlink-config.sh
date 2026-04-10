#!/bin/bash
# =============================================================================
# TérangaOS - Lien configuration live-build
# Lie le répertoire config/ à live-build-config/config/
# =============================================================================

set -e

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$TERANGA_DIR/config"
LIVE_CONFIG_DIR="$TERANGA_DIR/live-build-config/config"

echo "[TERANGOS] Liaison des configurations..."

# =============================================================================
# Package lists
# =============================================================================
echo "[TERANGOS] Copie package-lists..."
rm -rf "$LIVE_CONFIG_DIR/package-lists"/*
cp -r "$CONFIG_DIR/package-lists"/* "$LIVE_CONFIG_DIR/package-lists/"

# =============================================================================
# Hooks  
# =============================================================================
echo "[TERANGOS] Copie hooks..."
rm -rf "$LIVE_CONFIG_DIR/hooks"/*
cp -r "$CONFIG_DIR/hooks/live/"* "$LIVE_CONFIG_DIR/hooks/"

# =============================================================================
# Includes.chroot
# =============================================================================
echo "[TERANGOS] Copie includes.chroot..."
rm -rf "$LIVE_CONFIG_DIR/includes.chroot"/*
cp -r "$CONFIG_DIR/includes.chroot/"* "$LIVE_CONFIG_DIR/includes.chroot/"

echo "[OK] Configuration liée!"

# Listes
echo ""
echo "Package lists:"
ls -la "$LIVE_CONFIG_DIR/package-lists/"

echo ""
echo "Hooks:"
ls -la "$LIVE_CONFIG_DIR/hooks/"

echo ""
echo "Includes:"
ls -la "$LIVE_CONFIG_DIR/includes.chroot/"