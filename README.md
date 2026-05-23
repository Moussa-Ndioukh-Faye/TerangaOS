# TérangaOS — Optimized & Senegalese Edition

**"Dalal ak diam" — Bienvenue en paix**

Distribution GNU/Linux sénégalaise spécialisée en **Cybersécurité**, **Développement** et **IA**, optimisée pour la performance et adaptée aux services locaux.
Construite à l'**ESP/UCAD Dakar** 🌍

---

## 🏗️ Architecture & Optimisation

TérangaOS est conçu pour être à la fois puissant et léger :

- **Noyau Linux 6.8 LTS Optimisé :** Configuré pour une faible latence (`PREEMPT`), un scheduler réactif (`HZ=1000`) et une consommation mémoire réduite.
- **Interface Hyprland Ultra-Rapide :** Compositeur Wayland avec animations accélérées, VFR (Variable Frame Rate) activé et effets visuels coûteux désactivés pour une fluidité maximale.
- **Base Debian 12 (Djolof) :** La stabilité de Debian combinée à des outils de pointe.

## 🇸🇳 Services Sénégal & Innovation Locale

Une interface simplifiée et intelligente pour répondre aux besoins locaux :

- **Tableau de Bord "Sénégal" :** Accès direct (`SUPER + S`) aux services publics, universités et paiements.
- **Calendrier National :** Affichage en temps réel des jours fériés et événements nationaux dans la barre de tâches.
- **Mode Économie de Données :** Activez (`clic barre de tâches`) un mode restrictif pour économiser votre forfait mobile (bloque les mises à jour et les services IA gourmands).
- **Documentation Hors-Ligne :** Un guide complet (`SUPER + D`) accessible sans internet pour ne jamais être bloqué.

## 📦 Les Trois Piliers

### 🔒 Cybersécurité
Outils de pentest, audit et forensics (Metasploit, Nmap, Wireshark, Burp Suite, Hashcat, Aircrack-ng).

### ⚡ Développement
VS Code, Python 3.12, Node.js, Rust, Docker, et un terminal Zsh avec auto-complétion intelligente.

### 🤖 Intelligence Artificielle
**Ollama** local (Llama 3.1, Mistral) avec interface web et intégration bureau pour une IA privée et rapide.

---

## 🚀 Guide Rapide

### Installation des dépendances (Linux/WSL2)
```bash
chmod +x prepare-build.sh
./prepare-build.sh deps
```

### Construction de l'ISO
```bash
chmod +x build.sh
sudo ./build.sh
```

### Raccourcis Clavier Essentiels
| Touches | Action |
|---------|--------|
| `SUPER + Return` | Ouvrir le Terminal (Kitty) |
| `SUPER + S` | **Menu Services Sénégal** 🇸🇳 |
| `SUPER + D` | **Documentation Hors-Ligne** 📚 |
| `SUPER + R` | Lanceur d'applications (Wofi) |
| `SUPER + E` | Explorateur de fichiers (Thunar) |
| `SUPER + Q` | Fermer la fenêtre active |
| `SUPER + M` | Quitter la session |

## 🌓 Personnalisation Dynamique
TérangaOS intègre un moteur de thème intelligent (`teranga-theme-engine`) qui adapte l'interface selon l'heure :
- **Mode Djolof (06h - 18h) :** Palette Or et Terre pour une visibilité optimale le jour.
- **Mode Harmattan (18h - 06h) :** Palette sombre et apaisante pour le travail de nuit.


---

## 🎨 Identité Visuelle (Palette Djolof)
- **Or Djolof :** `#FFBE00` (Brand)
- **Terre de Dakar :** `#C85200` (Accent)
- **Mangrove :** `#4FFFAA` (Succès/Services Sénégal)
- **Nuit de Gorée :** `#0A0702` (Fond)

---

**Projet Académique — ESP/UCAD Dakar, Sénégal**
*"L'hospitalité numérique africaine au service de la performance."*
