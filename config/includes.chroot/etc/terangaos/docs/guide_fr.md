# Documentation TérangaOS — Guide de l'Hospitalité Numérique

Bienvenue dans la documentation hors-ligne de TérangaOS. Ce guide vous aidera à maîtriser votre système même sans connexion internet.

## 1. 🇸🇳 Services Sénégal
Pour accéder aux services locaux, utilisez le raccourci `SUPER + S`. 
Cela ouvre un menu interactif pour :
- Payer vos factures (Senelec, Sen'Eau)
- Accéder aux portails administratifs (Gouv.sn, Télédac)
- Consulter les ressources académiques (ESP, UCAD)

## 2. 🔒 Cybersécurité (Pilier 1, variantes *cyber* et *full*)
Les outils sont pré-installés (nmap, Wireshark, hashcat, sqlmap, Metasploit…). Pour lancer Metasploit, ouvrez un terminal et tapez :
```bash
msfconsole
```
Pour scanner un réseau local :
```bash
nmap -A [IP_CIBLE]
```

## 3. ⚡ Développement (Pilier 2)
Le système est prêt pour le code. 
- **Python, Node.js, Git, Docker** sont installés.
- **Docker :** le service démarre automatiquement. Vérifiez avec `docker ps`.

## 4. 🤖 Intelligence Artificielle (Pilier 3, variante *full*)
TérangaOS intègre **Ollama**. Le modèle se télécharge au premier lancement
(connexion Internet nécessaire, environ 5 Go) :
```bash
ollama run llama3.1
```
PyTorch, Jupyter, Transformers et LangChain sont dans `/opt/terangaos/ai`.
Lancez Jupyter avec `jupyter-lab`.

## 5. ⚙️ Optimisations
Votre OS est une "Optimized Edition". Il utilise :
- **ZRAM :** Pour une meilleure gestion de la mémoire.
- **Réglages réseau et mémoire** adaptés (voir `/etc/sysctl.d/99-terangaos.conf`).

## 6. 💾 Installer sur le disque
Ouvrez le menu (`SUPER + R`) et lancez **Installer TérangaOS**.
Dans la session live, l'utilisateur est `teranga` et le mot de passe `live`.

## 7. ✅ Vérifier le système
```bash
teranga-check
```

---
*ESP / UCAD Dakar — Sénégal*
