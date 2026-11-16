# Roadmap TérangaOS

## v1.0 (Djolof) — en cours
- [x] Build live-build sur Debian 13 (trixie)
- [x] Build depuis Ubuntu via conteneur Docker (`build-docker.sh`)
- [x] Variantes core / cyber / full
- [x] Bureau Hyprland + Waybar + Wofi + Kitty (paquets Debian)
- [x] Installateur graphique Calamares aux couleurs TérangaOS
- [x] Cybersécurité (nmap, Wireshark, hashcat, sqlmap, Metasploit…)
- [x] IA locale (Ollama, PyTorch CPU, Jupyter) dans un environnement isolé
- [x] Services Sénégal, calendrier, mode économie de données
- [x] Thème dynamique Djolof / Harmattan
- [x] SBOM JSON + SHA256, signature GPG optionnelle
- [x] CI GitHub Actions (vérification des scripts + ISO core)
- [ ] Premier build complet validé sur machine réelle

## v1.1 — Stabilisation
- [ ] Thème GRUB et écran de démarrage (Plymouth) TérangaOS
- [ ] Logo et diaporama Calamares propres à TérangaOS
- [ ] Miroirs Debian figés (snapshot.debian.org) pour des builds reproductibles
- [ ] Documentation hors ligne complète
- [ ] Volatility 3 et autres outils forensics hors Debian

## v2.0 — Professionnel
- [ ] Secure Boot (signature noyau + GRUB)
- [ ] Dépôt APT TérangaOS
- [ ] SBOM CycloneDX automatisé
- [ ] Builds reproductibles (reproducible-builds.org)
- [ ] Portage ARM64 (Raspberry Pi, etc.)

## Expérimental
- [ ] Build « from scratch » (toolchain, noyau, rootfs) — voir `experimental/from-scratch/`
- [ ] Layer Yocto `meta-terangaos`

## Long terme
- [ ] Modèles NLP wolof / pulaar
- [ ] OCR de documents sénégalais
- [ ] SOC intégré (cyberdéfense)
- [ ] Infrastructure cloud souveraine
