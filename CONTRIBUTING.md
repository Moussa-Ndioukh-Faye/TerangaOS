# Contribuer à TérangaOS

Merci de votre intérêt pour TérangaOS ! Ce document définit les standards et procédures pour contribuer.

## Structure du projet

Voir la section « Organisation du dépôt » du [README](README.md).

## Conventions

### Listes de paquets (`config/package-lists/`)
- Un fichier par domaine : `base`, `desktop`, `live`, `installer`, `dev`, `cybersec`, `ai`.
- Noms de paquets **Debian 13 (trixie)**, séparés par des espaces ou des retours à la ligne ; `#` pour les commentaires.
- Un paquet introuvable est ignoré avec un avertissement. S'il est indispensable, ajoutez-le à `REQUIRED_PACKAGES` dans `build.sh`.

### Hooks (`config/hooks/<common|cyber|full>/`)
- Format : `NNNN-description.hook.chroot` (NNNN = ordre d'exécution sur 4 chiffres, commun à tous les dossiers).
- `common/` : toutes les variantes · `cyber/` : cyber et full · `full/` : full uniquement.
- Les hooks sont de vrais fichiers versionnés (il n'y a plus de générateur) : modifiez-les directement et gardez-les exécutables (`chmod +x`).
- `set -euo pipefail` en tête. Tout ce qui télécharge hors des dépôts Debian doit pouvoir échouer sans bloquer le build (afficher `[WARN]`).
- Chaque hook doit être idempotent.

### Fichiers de l'image (`config/includes.chroot/`)
- Copiés tels quels dans le système. Les dotfiles vont dans `etc/skel/` (ils servent à l'utilisateur live et aux utilisateurs créés à l'installation).

### Scripts
- Bash, `set -euo pipefail`, fonctions documentées, pas de chemins absolus vers votre machine.
- Avant de proposer une modification : `bash -n` et `shellcheck -S warning` sur les scripts modifiés (la CI le fait aussi).

## Process de contribution

1. **Fork** le dépôt
2. **Créez une branche** : `git checkout -b feature/ma-modification`
3. **Commitez** vos changements (messages clairs en anglais ou français)
4. **Testez** : au minimum `sudo ./build.sh prepare --variant core`, idéalement `./build-docker.sh --variant core`
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
