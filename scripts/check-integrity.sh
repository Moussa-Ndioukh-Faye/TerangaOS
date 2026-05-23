#!/bin/bash
# T??rangaOS ??? V??rificateur d'Int??grit?? des Piliers
# V??rifie que les outils essentiels sont pr??sents

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_bin() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}[OK]${NC} $1 est pr??sent"
    else
        echo -e "${RED}[MANQUANT]${NC} $1"
    fi
}

echo "--- V??rification Pilier Cybers??curit?? ---"
check_bin nmap
check_bin msfconsole
check_bin wireshark
check_bin hashcat

echo -e "\n--- V??rification Pilier D??veloppement ---"
check_bin code
check_bin python3
check_bin node
check_bin docker
check_bin git

echo -e "\n--- V??rification Pilier Intelligence Artificielle ---"
check_bin ollama
check_bin jupyter-lab

echo -e "\n--- V??rification Interface S??n??gal ---"
check_bin wofi
check_bin waybar
check_bin hyprland
