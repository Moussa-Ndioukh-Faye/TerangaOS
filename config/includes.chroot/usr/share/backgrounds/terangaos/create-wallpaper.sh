#!/bin/bash
# =============================================================================
# TérangaOS - Générateur de Wallpaper Professionnel
# Crée un wallpaper avec le thème Djolof
# =============================================================================

set -e

WALLPAPER_DIR="/usr/share/backgrounds/terangaos"
WALLPAPER="$WALLPAPER_DIR/teranga-wallpaper.png"
WIDTH=1920
HEIGHT=1080

mkdir -p "$WALLPAPER_DIR"

# Couleurs TérangaOS (Djolof Theme)
COLOR_BG="#0A0702"        # Nuit de Gorée
COLOR_SURFACE="#1A1408"     # Braise
COLOR_ACCENT="#FFBE00"       # Or Djolof
COLOR_TERRE="#C85200"      # Terre de Dakar

echo "[TERANGOS] Génération wallpaper..."
echo "[TERANGOS] Resolution: ${WIDTH}x${HEIGHT}"

if command -v convert &>/dev/null; then
    # Créer le wallpaper avec ImageMagick
    convert -size ${WIDTH}x${HEIGHT} gradient:"$COLOR_BG"-"$COLOR_SURFACE" \
        -fill "$COLOR_ACCENT" -draw "circle $((WIDTH/2)),$((HEIGHT/2)) $((WIDTH/2)),$((HEIGHT/2-150))" \
        -fill "$COLOR_TERRE" -draw "circle $((WIDTH/2)),$((HEIGHT/2)) $((WIDTH/2)),$((HEIGHT/2-100))" \
        -fill "$COLOR_SURFACE" -draw "circle $((WIDTH/2)),$((HEIGHT/2)) $((WIDTH/2)),$((HEIGHT/2-50))" \
        -fill "$COLOR_ACCENT" -draw "rectangle 100,$((HEIGHT-80)) $((WIDTH-100)),$((HEIGHT-70))" \
        -fill "$COLOR_BG" -pointsize 48 -gravity center -annotate +0+0 "TérangaOS 1.0" \
        -fill "$COLOR_TERRE" -pointsize 24 -gravity south -annotate +0+50 "Djolof • L'hospitalité numérique africaine" \
        "$WALLPAPER"
    
    echo "[OK] Wallpaper créé: $WALLPAPER"
else
    # Fallback: créer un wallpaper simple sans ImageMagick
    echo "[WARN] ImageMagick non disponible, création wallpaper minimal..."
    
    # Créer un fichier PPM minimal (format simple)
    {
        echo "P6"
        echo "$WIDTH $HEIGHT"
        echo "255"
        # Generate simple gradient pixels
        for y in $(seq 1 $HEIGHT); do
            for x in $(seq 1 $WIDTH); do
                # RGB values for dark gradient
                r=$((10 + (x * 5 / WIDTH)))
                g=$((7 + (x * 4 / WIDTH)))
                b=$((2 + (x * 2 / WIDTH)))
                printf "\\%03o\\%03o\\%03o" $r $g $b
            done
        done
    } > "$WALLPAPER_DIR/teranga-wallpaper.ppm"
    
    # Convertir en PNG si possible, sinon garder PPM
    if command -v ppmtopng &>/dev/null; then
        ppmtopng "$WALLPAPER_DIR/teranga-wallpaper.ppm" > "$WALLPAPER"
        rm "$WALLPAPER_DIR/teranga-wallpaper.ppm"
    else
        mv "$WALLPAPER_DIR/teranga-wallpaper.ppm" "$WALLPAPER"
    fi
    
    echo "[OK] Wallpaper minimal créé: $WALLPAPER"
fi

# Vérifier le fichier
if [ -f "$WALLPAPER" ]; then
    SIZE=$(du -h "$WALLPAPER" | cut -f1)
    echo "[OK] Fichier: $WALLPAPER ($SIZE)"
else
    echo "[ERREUR] Échec création wallpaper"
    exit 1
fi