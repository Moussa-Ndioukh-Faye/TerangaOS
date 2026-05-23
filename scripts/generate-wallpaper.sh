#!/bin/bash
# TérangaOS — Génération du wallpaper SVG -> PNG
# Script exécuté lors du hook de branding

mkdir -p /usr/share/backgrounds/terangaos

# Générer le wallpaper SVG (converti en PNG ensuite)
cat > /tmp/terangaos-wallpaper.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080" viewBox="0 0 1920 1080">
  <defs>
    <!-- Fond dégradé nuit de Gorée -->
    <radialGradient id="bg1" cx="30%" cy="70%" r="60%">
      <stop offset="0%" stop-color="#3A1800" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="#0a0702" stop-opacity="1"/>
    </radialGradient>
    <radialGradient id="bg2" cx="75%" cy="25%" r="50%">
      <stop offset="0%" stop-color="#1F1200" stop-opacity="0.5"/>
      <stop offset="100%" stop-color="#0a0702" stop-opacity="0"/>
    </radialGradient>

    <!-- Motif kente géométrique -->
    <pattern id="kente" x="0" y="0" width="80" height="80" patternUnits="userSpaceOnUse">
      <line x1="0" y1="20" x2="80" y2="20" stroke="#FFBE00" stroke-width="0.6" opacity="0.12"/>
      <line x1="0" y1="60" x2="80" y2="60" stroke="#C85200" stroke-width="0.4" opacity="0.1"/>
      <line x1="20" y1="0" x2="20" y2="80" stroke="#FFBE00" stroke-width="0.4" opacity="0.1"/>
      <line x1="60" y1="0" x2="60" y2="80" stroke="#C85200" stroke-width="0.6" opacity="0.12"/>
      <rect x="20" y="20" width="40" height="40" fill="none" stroke="#FFBE00" stroke-width="0.3" opacity="0.06"/>
    </pattern>

    <filter id="glow">
      <feGaussianBlur stdDeviation="8" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>

    <filter id="softglow">
      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <!-- Fond -->
  <rect width="1920" height="1080" fill="#0a0702"/>
  <rect width="1920" height="1080" fill="url(#bg1)"/>
  <rect width="1920" height="1080" fill="url(#bg2)"/>
  <rect width="1920" height="1080" fill="url(#kente)"/>

  <!-- Cercles décoratifs -->
  <circle cx="300" cy="750" r="400" fill="none" stroke="#C85200" stroke-width="0.5" opacity="0.08"/>
  <circle cx="300" cy="750" r="300" fill="none" stroke="#FFBE00" stroke-width="0.4" opacity="0.06"/>
  <circle cx="1650" cy="280" r="350" fill="none" stroke="#FFBE00" stroke-width="0.5" opacity="0.07"/>

  <!-- Hexagone logo centré -->
  <g transform="translate(960, 500)">
    <!-- Hexagone extérieur -->
    <polygon points="0,-160 138.6,-80 138.6,80 0,160 -138.6,80 -138.6,-80"
      fill="none" stroke="#FFBE00" stroke-width="2" opacity="0.35" filter="url(#glow)"/>
    <!-- Hexagone intérieur -->
    <polygon points="0,-100 86.6,-50 86.6,50 0,100 -86.6,50 -86.6,-50"
      fill="none" stroke="#C85200" stroke-width="1" opacity="0.2" stroke-dasharray="8 4"/>
    <!-- T stylisé -->
    <line x1="-55" y1="-25" x2="55" y2="-25" stroke="#FFBE00" stroke-width="8" stroke-linecap="round" opacity="0.9" filter="url(#softglow)"/>
    <line x1="0" y1="-25" x2="0" y2="60" stroke="#FFBE00" stroke-width="8" stroke-linecap="round" opacity="0.9" filter="url(#softglow)"/>
    <!-- Points aux sommets -->
    <circle cx="0" cy="-160" r="4" fill="#FFBE00" opacity="0.7"/>
    <circle cx="138.6" cy="-80" r="3" fill="#C85200" opacity="0.6"/>
    <circle cx="138.6" cy="80" r="3" fill="#C85200" opacity="0.6"/>
    <circle cx="0" cy="160" r="4" fill="#FFBE00" opacity="0.7"/>
    <circle cx="-138.6" cy="80" r="3" fill="#C85200" opacity="0.6"/>
    <circle cx="-138.6" cy="-80" r="3" fill="#C85200" opacity="0.6"/>
  </g>

  <!-- Texte TérangaOS -->
  <text x="960" y="730"
    font-family="serif"
    font-size="72"
    font-weight="900"
    fill="#FFBE00"
    text-anchor="middle"
    opacity="0.9"
    filter="url(#softglow)">TérangaOS</text>

  <!-- Tagline -->
  <text x="960" y="775"
    font-family="monospace"
    font-size="16"
    fill="#F5EDD8"
    text-anchor="middle"
    opacity="0.35"
    letter-spacing="6">VERSION 1.0 · CODENAME DJOLOF · ESP/UCAD DAKAR</text>

  <!-- Pillars -->
  <text x="760" y="830" font-family="monospace" font-size="13" fill="#FF6B6B" text-anchor="middle" opacity="0.6">🔒 CYBERSÉCURITÉ</text>
  <text x="960" y="830" font-family="monospace" font-size="13" fill="#FFBE00" text-anchor="middle" opacity="0.6">⚡ DÉVELOPPEMENT</text>
  <text x="1160" y="830" font-family="monospace" font-size="13" fill="#7EC8FF" text-anchor="middle" opacity="0.6">🤖 INTELLIGENCE ARTIFICIELLE</text>

  <!-- Trait décoratif bas -->
  <line x1="560" y1="810" x2="860" y2="810" stroke="#FFBE00" stroke-width="0.5" opacity="0.2"/>
  <line x1="1060" y1="810" x2="1360" y2="810" stroke="#FFBE00" stroke-width="0.5" opacity="0.2"/>
</svg>
SVGEOF

# Convertir SVG en PNG avec rsvg-convert (si disponible)
if command -v rsvg-convert &>/dev/null; then
  rsvg-convert -w 1920 -h 1080 /tmp/terangaos-wallpaper.svg \
    -o /usr/share/backgrounds/terangaos/djolof.png
  echo "[WALLPAPER] ✓ djolof.png généré (1920x1080)"
elif command -v convert &>/dev/null; then
  convert /tmp/terangaos-wallpaper.svg \
    -resize 1920x1080 \
    /usr/share/backgrounds/terangaos/djolof.png
  echo "[WALLPAPER] ✓ djolof.png généré via ImageMagick"
else
  # Fallback: copier le SVG directement
  cp /tmp/terangaos-wallpaper.svg \
    /usr/share/backgrounds/terangaos/djolof.svg
  # Créer un PNG minimaliste via Python
  python3 -c "
import struct, zlib, base64

def make_png(w, h, color):
    def chunk(name, data):
        c = zlib.crc32(name + data) & 0xffffffff
        return struct.pack('>I', len(data)) + name + data + struct.pack('>I', c)
    r, g, b = color
    raw = b''
    for _ in range(h):
        row = b'\x00' + bytes([r, g, b] * w)
        raw += row
    compressed = zlib.compress(raw, 9)
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
    png += chunk(b'IDAT', compressed)
    png += chunk(b'IEND', b'')
    return png

with open('/usr/share/backgrounds/terangaos/djolof.png', 'wb') as f:
    f.write(make_png(1920, 1080, (10, 7, 2)))
print('PNG fallback créé')
"
  echo "[WALLPAPER] ✓ djolof.png créé (fallback sombre)"
fi

# Copie d'une variante claire
cp /usr/share/backgrounds/terangaos/djolof.png \
   /usr/share/backgrounds/terangaos/djolof-alt.png 2>/dev/null || true

rm -f /tmp/terangaos-wallpaper.svg
