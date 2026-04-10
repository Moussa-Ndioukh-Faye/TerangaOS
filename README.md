# TérangaOS

**"Dalal ak diam" — Bienvenue en paix**

Distribution GNU/Linux spécialisée en **cybersécurité**, **développement** et **intelligence artificielle**.
Construite à l'**ESP/UCAD Dakar, Sénégal** 🌍

**Version**: 1.0 | **Codename**: Djolof | **Base**: Debian 12 Bookworm

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│              TérangaOS 1.0 (Djolof)               │
├─────────────────────────────────────────────────────┤
│  🪟 HYPRLAND 0.41                                 │
│     Compositeur Wayland · Tiling dynamique           │
├─────────────────────────────────────────────────────┤
│  🌊 WAYLAND / PIPEWIRE                             │
│     Wayland protocols · XWayland · Pipewire 1.0    │
├─────────────────────────────────────────────────────┤
│  ⚙️  SYSTEMD + SDDM                                │
│     systemd 254 · SDDM · Polkit · D-Bus             │
├─────────────────────────────────────────────────────┤
│  🐧 KERNEL 6.8 LTS                                 │
│     Linux 6.8 · glibc 2.37 · busybox · bash 5.2   │
├─────────────────────────────────────────────────────┤
│  💻 HARDWARE (amd64/x86_64)                        │
└─────────────────────────────────────────────────────┘
```

## 📦 Les Trois Piliers

### 🔒 Cybersécurité
| Outil | Rôle |
|-------|------|
| nmap | Scan réseau |
| Wireshark | Analyse paquets |
| Metasploit | Framework exploit |
| Burp Suite | Proxy web |
| Hashcat | Cracking passwords |
| Aircrack-ng | Audit Wi-Fi |
| Volatility 3 | Forensics mémoire |

### ⚡ Développement
| Outil | Rôle |
|-------|------|
| VS Code | Éditeur principal |
| Python 3.12 | Scripting & IA |
| Node.js / npm | Runtime JS |
| Rust | Systèmes/performance |
| Docker | Conteneurs |
| Git + GitHub CLI | Versioning |

### 🤖 Intelligence Artificielle
| Outil | Rôle |
|-------|------|
| Ollama | LLM local (Llama 3, Mistral) |
| Open WebUI | Interface chat IA |
| Jupyter Lab | Notebooks |
| PyTorch | Deep learning |
| LangChain | Pipelines LLM |

---

## 📁 Structure du Projet

```
TerangaOS/
├── build.sh                     # Script principal live-build
├── clean.sh                     # Nettoyage
│
├── config/
│   ├── package-lists/
│   │   ├── base.list.chroot     # Paquets système
│   │   ├── desktop.list.chroot  # Hyprland + Wayland
│   │   ├── cybersec.list.chroot # Outils sécurité
│   │   ├── dev.list.chroot     # Développement
│   │   └── ai.list.chroot      # IA (Python, Jupyter)
│   │
│   ├── hooks/live/
│   │   ├── 0001-base-config.hook.chroot
│   │   ├── 0002-hyprland-build.hook.chroot
│   │   ├── 0003-ollama-branding.hook.chroot
│   │   ├── 0004-metasploit.hook.chroot
│   │   └── 0005-users-setup.hook.chroot
│   │
│   └── includes.chroot/
│       ├── etc/
│       │   ├── os-release
│       │   ├── motd
│       │   ├── hostname
│       │   └── sddm.conf.d/
│       │
│       └── home/teranga/.config/
│           ├── hypr/hyprland.conf
│           ├── waybar/config + style.css
│           ├── kitty/kitty.conf
│           ├── wofi/config + style.css
│           └── mako/config
│
├── scripts/
│   ├── write-hooks.sh          # Crée les hooks
│   ├── inject-configs.sh       # Injecte configs Hyprland
│   ├── config-hyprland.sh     # Config Hyprland
│   ├── config-waybar.sh       # Config Waybar
│   └── config-desktop.sh      # Config Desktop
│
├── poky/                       # Yocto build system
├── meta-terangaos/              # Layer Yocto custom
├── live-build-config/           # Alternative live-build
│
├── linux-master/               # Linux Kernel 6.x
├── gcc-master/                 # GCC Compiler
├── glibc/                     # GNU C Library
│
├── openssl/ zlib/ ncurses/
├── busybox/ coreutils/ bash/
├── grub/ syslinux/ openrc/
├── dracut/ kbd/
│
├── xserver/ wayland/ sddm/
├── NetworkManager/ pipewire/
│
├── terangaos_complete.html      # Guide de construction
├── terangaos_brand_kit.html    # Kit de marque
│
└── README.md
```

---

## 🚀 Construction Rapide

### Prérequis (Linux/WSL2)

```bash
sudo apt update
sudo apt install -y \
    live-build debootstrap git curl wget \
    cmake ninja-build meson \
    build-essential gcc g++ \
    libwayland-dev libxkbcommon-dev \
    libpango1.0-dev libcairo2-dev \
    libseat-dev libinput-dev \
    pkg-config
```

### Build

```bash
# Cloner le projet
git clone https://github.com/terangaos/terangaos.git
cd terangaos

# Exécuter le build
chmod +x build.sh
sudo ./build.sh

# Ou avec live-build directement
cd live-build-config
sudo lb build
```

### Résultat

```
output/
└── terangaos-1.0-amd64.iso    # ~4-6 Go
```

---

## 🎨 Thème

### Palette
| Couleur | Hex | Usage |
|---------|-----|-------|
| Or Djolof | #FFBE00 | Principal |
| Terre de Dakar | #C85200 | Accent |
| Harmattan | #FF7A30 | Warning |
| Nuit de Gorée | #0A0702 | Background |
| Braise | #1A1408 | Surface |
| Sable du Sahel | #F5EDD8 | Texte |
| Mangrove | #4FFFAA | Succès |
| Atlantique | #7EC8FF | Info/IA |

### Typographie
- **Playfair Display** — Titres
- **Syne** — Corps de texte
- **JetBrains Mono** — Code/Terminal

---

## 📋 Scripts Disponibles

| Script | Fonction |
|--------|----------|
| `build.sh` | Build principal avec live-build |
| `clean.sh` | Nettoyage du build |
| `scripts/write-hooks.sh` | Crée les hooks d'installation |
| `scripts/inject-configs.sh` | Injecte les configs Hyprland |
| `scripts/config-hyprland.sh` | Configure Hyprland |
| `scripts/config-waybar.sh` | Configure Waybar |
| `scripts/config-desktop.sh` | Configure Kitty/Wofi/Mako |

---

## 🔧 Configuration

### Locale
```
fr_FR.UTF-8
```

### Timezone
```
Africa/Dakar
```

### Hostname
```
terangaos
```

### Utilisateur
```
Username: teranga
Password: teranga
Shell: zsh
Groups: sudo, video, audio, input, netdev, plugdev
```

---

## 📚 Documentation

- [Guide de Construction Complet](terangaos_complete.html)
- [Brand Kit & Architecture](terangaos_brand_kit.html)

---

## 🤝 Contribution

Projet académique — ESP/UCAD Dakar, Sénégal
Licence: GPL-3.0

---

## 🗺️ Roadmap

| Phase | Description | Status |
|-------|-------------|--------|
| 01 | Environnement de build | ✅ |
| 02 | Configuration de base | ✅ |
| 03 | Package lists (3 piliers) | ✅ |
| 04 | Theming & Branding | ✅ |
| 05 | Build & Test VM | 🔄 |
| 06 | ISO finale & Livraison | ⏳ |

---

**"Dalal ak diam" — L'hospitalité numérique africaine**
