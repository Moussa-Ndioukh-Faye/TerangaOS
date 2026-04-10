#!/bin/bash
# =============================================================================
# TérangaOS - Téléchargeur de Wallpaper Professionnel
# =============================================================================

WALLPAPER_DIR="/usr/share/backgrounds/terangaos"
WALLPAPER="$WALLPAPER_DIR/teranga-wallpaper.png"
mkdir -p "$WALLPAPER_DIR"

# Download a professional, abstract African-themed wallpaper
# Using a high-quality Unsplash image (free for commercial use)
WALLPAPER_URL="https://images.unsplash.com/photo-1519810755548-39dbc094b1c3?w=1920&q=80"

if command -v curl &>/dev/null; then
    echo "[TERANGOS] Téléchargement wallpaper..."
    curl -L -o "$WALLPAPER" "$WALLPAPER_URL" 2>/dev/null
    
    if [ -f "$WALLPAPER" ] && [ -s "$WALLPAPER" ]; then
        echo "[OK] Wallpaper téléchargé: $WALLPAPER"
    else
        echo "[ERREUR] Échec téléchargement"
        exit 1
    fi
else
    echo "[ERREUR] curl non disponible"
    exit 1
fi