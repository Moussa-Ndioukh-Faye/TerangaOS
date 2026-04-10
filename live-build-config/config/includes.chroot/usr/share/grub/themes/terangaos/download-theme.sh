#!/bin/bash
# =============================================================================
# TérangaOS - Téléchargeur de Wallpaper GRUB
# =============================================================================

GRUB_DIR="/usr/share/grub/themes/terangaos"
mkdir -p "$GRUB_DIR"

WALLPAPER_URL="https://images.unsplash.com/photo-1531604908062-7f9b8c63b86f?w=800&q=80"

echo "[TERANGOS] Téléchargement wallpaper GRUB..."
curl -L -o "$GRUB_DIR/terangaos-grub.png" "$WALLPAPER_URL" 2>/dev/null

if [ -f "$GRUB_DIR/terangaos-grub.png" ] && [ -s "$GRUB_DIR/terangaos-grub.png" ]; then
    echo "[OK] Wallpaper GRUB créé"
else
    # Fallback: create minimal placeholder
    echo "[WARN] Utilisation fallback..."
    convert -size 800x600 gradient:'#0A0702'-'#1A1408' "$GRUB_DIR/terangaos-grub.png" 2>/dev/null || true
fi