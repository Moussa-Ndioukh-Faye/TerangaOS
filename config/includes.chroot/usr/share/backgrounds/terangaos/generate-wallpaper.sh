#!/bin/bash
# =============================================================================
# TérangaOS - Générateur de Wallpaper
# Crée le wallpaper par défaut si absent
# =============================================================================

WALLPAPER_DIR="/usr/share/backgrounds/terangaos"
WALLPAPER="$WALLPAPER_DIR/teranga-wallpaper.png"

# Couleurs TérangaOS (Djolof Theme)
COLOR_BG="#0A0702"        # Nuit de Gorée
COLOR_ACCENT="#FFBE00"     # Or Djolof
COLOR_TERRE="#C85200"     # Terre de Dakar

mkdir -p "$WALLPAPER_DIR"

# Générer avec ImageMagick
if command -v convert &>/dev/null; then
    echo "[TERANGOS] Génération wallpaper..."
    
    convert -size 1920x1080 gradient:"$COLOR_BG"-"#1A1408" \
        -fill "$COLOR_ACCENT" -pointsize 72 -gravity center -annotate +0+0 "TérangaOS\nDjolof" \
        -fill "$COLOR_TERRE" -pointsize 24 -gravity south -annotate+0 "L'hospitalité numérique africaine" \
        "$WALLPAPER"
    
    echo "[OK] Wallpaper créé: $WALLPAPER"
else
    echo "[ERREUR] ImageMagick non disponible"
    echo "Installez imagemagick: apt install imagemagick"
    exit 1
fi