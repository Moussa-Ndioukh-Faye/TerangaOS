#!/bin/bash
# TérangaOS — supprime les dossiers de build (cache des paquets compris)
# Usage : sudo ./clean.sh           (toutes les variantes)
#         sudo ./clean.sh core      (une seule variante)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$(id -u)" -ne 0 ]; then
    echo "Lancez avec sudo : les fichiers de build appartiennent à root." >&2
    exit 1
fi

if [ $# -gt 0 ]; then variants=("$@"); else variants=(core cyber full); fi
for v in "${variants[@]}"; do
    ./build.sh clean --variant "$v"
done
rm -f build/*.iso build/*.sha256 build/*.asc build/*.log
rmdir build 2>/dev/null || true
echo "[TERANGA] Nettoyage terminé."
