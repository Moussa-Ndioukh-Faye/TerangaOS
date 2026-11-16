# Contribuer à TérangaOS

Merci de votre intérêt pour TérangaOS ! Ce document définit les standards et procédures pour contribuer.

## Structure du projet

```
TerangaOS/
├── config/                  # Configuration live-build
│   ├── package-lists/       # Paquets par domaine (base, desktop, live, ai, dev, cybersec)
│   ├── includes.chroot/     # Fichiers injectés dans l'image
│   └── hooks/live/          # Hooks générés (NE PAS commiter — voir scripts/write-hooks.sh)
├── scripts/                 # Scripts de configuration
│   └── write-hooks.sh       # GÉNÈRE les hooks dans config/hooks/live/
├── live-build-config/       # Build directory (généré par build.sh, NE PAS commiter)
├── build.sh                 # Build principal via live-build
├── build-all.sh             # Build complet from scratch
├── build-kernel.sh          # Compilation du kernel Linux
├── build-rootfs.sh          # Construction rootfs
├── build-toolchain.sh       # Toolchain GCC+glibc
├── build-iso.sh             # Génération ISO manuelle
└── meta-terangaos/          # Layer Yocto/OpenEmbedded
```

## Conventions

### Package lists
- Un fichier par domaine : `base.list.chroot`, `desktop.list.chroot`, `dev.list.chroot`, etc.
- Préfixe domaine dans le nom du fichier
- Un paquet par ligne, ou groupé par fonction si inséparable

### Hooks
- Format : `NNNN-description.hook.chroot` (NNNN = numéro d'ordre sur 4 chiffres)
- Les hooks sont GÉNÉRÉS par `scripts/write-hooks.sh` — ne pas les modifier directement dans `config/hooks/live/`
- Toujours modifier `scripts/write-hooks.sh` puis le regénerer
- Chaque hook doit être idempotent (exécutable plusieurs fois sans effet de bord)
- Utiliser `set -e` en début de hook

### Scripts
- `scripts/` pour les outils de configuration
- `build-*.sh` pour les pipelines de build
- Toujours utiliser `set -e` et documenter les fonctions

## Process de contribution

1. **Fork** le dépôt
2. **Créez une branche** : `git checkout -b feature/ma-modification`
3. **Commitez** vos changements (messages clairs en anglais ou français)
4. **Testez** : exécutez `./build.sh deps && ./build.sh prepare` au minimum
5. **Ouvrez une Pull Request** vers `main`

## Standards de code

- Shell scripts : bash, `set -e`, fonctions documentées
- Configs : indentations cohérentes, pas de tabs parasites
- Noms de variables en UPPERCASE pour les constantes, lowercase pour les locales
- Éviter les chemins absolus (utiliser `$TERANGA_DIR`)

## Rapporter un bug

Utilisez GitHub Issues avec :
- Description du problème
- Environnement (OS, version)
- Logs pertinents
- Étapes pour reproduire

## Roadmap

Voir ROADMAP.md pour les jalons du projet.
