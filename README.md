# 🌍 TérangaOS 1.0 — « Djolof »

Distribution GNU/Linux basée sur **Debian 13 (trixie)**, avec le bureau **Hyprland**, pensée pour l'Afrique de l'Ouest autour de trois piliers : 🔒 cybersécurité, ⚡ développement et 🤖 intelligence artificielle.

*Projet ESP / UCAD · Dakar, Sénégal — « Dalal ak diam »*

## 🎭 Variantes

| Variante | Contenu | ISO (environ) | Build (environ) |
| :--- | :--- | :--- | :--- |
| `core` | Hyprland, Waybar, Kitty, Firefox, Python, Node.js, Docker, installateur Calamares | 2,5 Go | 30–45 min |
| `cyber` | `core` + nmap, Wireshark, hashcat, sqlmap, hydra, Metasploit… | 4 Go | 45–60 min |
| `full` (défaut) | `cyber` + Ollama, PyTorch (CPU), Jupyter, Transformers, LangChain | 7 Go | 60–120 min |

Les durées dépendent surtout de la connexion Internet : tous les paquets sont téléchargés pendant le build.

## 🚀 Construire l'ISO

### Sur Ubuntu (dual boot) — recommandé

Le paquet `live-build` d'Ubuntu est trop ancien pour Debian 13 : `build-docker.sh` lance donc le build dans un conteneur Debian.

```bash
# 1. Installer Docker (une seule fois, puis se déconnecter/reconnecter)
sudo apt install docker.io git
sudo usermod -aG docker $USER

# 2. Cloner dans votre dossier personnel Ubuntu (PAS sur la partition Windows)
cd ~
git clone https://github.com/Moussa-Ndioukh-Faye/TerangaOS.git
cd TerangaOS

# 3. Commencer par la variante la plus légère
./build-docker.sh --variant core
```

L'ISO arrive dans `build/terangaos-1.0-core-amd64.iso` (avec son `.sha256`).
Prévoyez **25 Go libres** pour `core` et **40 Go** pour `full`.

### Sur Debian 13

```bash
sudo apt install live-build debootstrap xorriso squashfs-tools isolinux \
    syslinux-common grub-efi-amd64-bin grub-pc-bin mtools dosfstools
sudo ./build.sh --variant core
```

### Commandes utiles

```bash
./build.sh help                         # toutes les options
sudo ./build.sh check                   # vérifier la machine
sudo ./build.sh clean --variant core    # supprimer un build
sudo ./clean.sh                         # tout supprimer, cache compris
```

> ⚠️ Ne lancez pas le build depuis WSL ou un dossier Windows/OneDrive : ces systèmes de fichiers cassent `debootstrap` (erreur « tar failed »). `build.sh` refuse désormais de démarrer dans ce cas.

## 🧪 Tester l'ISO

```bash
sudo apt install qemu-system-x86 ovmf
qemu-system-x86_64 -enable-kvm -m 4G -smp 2 -cdrom build/terangaos-1.0-core-amd64.iso
```

Ou créez une machine virtuelle VirtualBox/VMware (4 Go de RAM minimum), ou copiez l'ISO sur une clé USB avec `sudo dd if=build/terangaos-1.0-core-amd64.iso of=/dev/sdX bs=4M status=progress` (vérifiez bien `/dev/sdX` !).

Session live : utilisateur **`teranga`**, mot de passe **`live`**, connexion automatique.

| Raccourci | Action |
| :--- | :--- |
| `SUPER + Entrée` | Terminal (Kitty) |
| `SUPER + R` | Menu des applications (dont « Installer TérangaOS ») |
| `SUPER + S` | Services sénégalais |
| `SUPER + D` | Documentation hors ligne |
| `SUPER + E` | Fichiers (Thunar) |

Dans un terminal : `teranga-check` vérifie que les outils de la variante sont bien présents.

## 🏗️ Organisation du dépôt

```
build.sh                  Build principal (live-build, Debian 13)
build-docker.sh           Build depuis Ubuntu ou toute machine avec Docker
clean.sh                  Nettoyage des builds
config/
  package-lists/          Paquets Debian par domaine (base, desktop, dev, cybersec, ai…)
  hooks/common/           Scripts exécutés dans l'image, toutes variantes
  hooks/cyber/            … variantes cyber et full (Metasploit)
  hooks/full/             … variante full (Ollama, pile IA)
  includes.chroot/        Fichiers copiés tels quels dans l'image (dotfiles, scripts teranga-*)
docs/                     Charte graphique et présentation
experimental/from-scratch Pipeline « Linux from scratch » (non fonctionnel, voir son README)
```

Les paquets absents de Debian sont signalés et ignorés au moment du build ; seuls quelques paquets indispensables (Hyprland, SDDM, Calamares…) arrêtent le build s'ils manquent.

## 🛡️ Sécurité

- Les paquets viennent des dépôts Debian signés.
- Metasploit (dépôt Rapid7), Ollama et les paquets Python IA viennent de sources externes : leur échec n'empêche pas la création de l'ISO, il est signalé dans le journal.
- Chaque ISO contient l'inventaire de ses paquets dans `/etc/terangaos-sbom.json` et est livrée avec un fichier SHA256. Signature GPG possible : `GPG_KEY=<id> sudo -E ./build.sh`.

Voir [SECURITY.md](SECURITY.md), [ROADMAP.md](ROADMAP.md) et [CONTRIBUTING.md](CONTRIBUTING.md).
