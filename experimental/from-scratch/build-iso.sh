#!/bin/bash
# =============================================================================
# TérangaOS - Génération de l'image ISO
# =============================================================================

set -e

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TERANGA_DIR/build"
IMAGES_DIR="$BUILD_DIR/images"
ISO_DIR="$BUILD_DIR/iso"

source "$BUILD_DIR/config.sh" 2>/dev/null || true

echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║          TérangaOS - Génération de l'ISO          ║"
echo "  ╚══════════════════════════════════════════════════╝"

# =============================================================================
# Préparation de l'image
# =============================================================================
prepare_iso_structure() {
    echo "[INFO] Préparation de la structure ISO..."
    
    mkdir -p "$ISO_DIR"/{boot,boot/grub,x86_64-efi,EFI/boot,isolinux}
    
    # Copier le noyau et l'initramfs
    if [ -f "$BUILD_DIR/rootfs/boot/vmlinuz-terangaos" ]; then
        cp "$BUILD_DIR/rootfs/boot/vmlinuz-terangaos" "$ISO_DIR/boot/vmlinuz"
    fi
    
    if [ -f "$IMAGES_DIR/initramfs-terangaos.img" ]; then
        cp "$IMAGES_DIR/initramfs-terangaos.img" "$ISO_DIR/boot/initrd.img"
    fi
    
    # Copier le système de fichiers
    mkdir -p "$ISO_DIR/live"
    
    echo "[OK] Structure ISO préparée"
}

# =============================================================================
# Création du système de fichiers compressé (SquashFS)
# =============================================================================
create_squashfs() {
    echo "[INFO] Création du système de fichiers compressé..."
    
    if [ -d "$BUILD_DIR/rootfs" ]; then
        # Création du SquashFS
        if command -v mksquashfs &> /dev/null; then
            mksquashfs "$BUILD_DIR/rootfs" \
                       "$ISO_DIR/live/filesystem.squashfs" \
                       -comp xz \
                       -e boot \
                       -e proc \
                       -e sys \
                       -e dev \
                       -e run \
                       -e tmp
        else
            echo "[WARN] mksquashfs non disponible. Création d'une archive tar.gz..."
            tar -czf "$ISO_DIR/live/filesystem.tar.gz" -C "$BUILD_DIR/rootfs" .
        fi
    else
        echo "[ERROR] rootfs non trouvé. Exécutez d'abord build-rootfs.sh"
        exit 1
    fi
    
    echo "[OK] Système de fichiers compressé"
}

# =============================================================================
# Configuration de GRUB pour l'ISO
# =============================================================================
configure_grub() {
    echo "[INFO] Configuration de GRUB..."
    
    # Menu GRUB
    cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=5
set default=0

menuentry "TérangaOS 1.0 (Djolof) - Live" {
    linux /boot/vmlinuz boot=live persistence quiet splash
    initrd /boot/initrd.img
}

menuentry "TérangaOS 1.0 - Mode texte" {
    linux /boot/vmlinuz boot=live persistence textonly quiet
    initrd /boot/initrd.img
}

menuentry "TérangaOS - Vérification mémoire" {
    linux16 /boot/memtest86+/memtest.bin
}

menuentry "Démarrer depuis le disque dur" {
    search --no-floppy --set=root --hint-bios=hd0,msdos1
    chainloader +1
}
EOF

    # Copier les fichiers GRUB
    if [ -d "$TERANGA_DIR/grub" ]; then
        echo "[INFO] GRUB source disponible"
    fi
    
    echo "[OK] GRUB configuré"
}

# =============================================================================
# Configuration de ISOLINUX (BIOS)
# =============================================================================
configure_isolinux() {
    echo "[INFO] Configuration de ISOLINUX..."
    
    cat > "$ISO_DIR/isolinux/isolinux.cfg" << 'EOF'
DEFAULT teranga
LABEL teranga
    MENU LABEL TérangaOS 1.0 (Djolof) - Live
    KERNEL /boot/vmlinuz
    APPEND boot=live persistence initrd=/boot/initrd.img quiet splash
LABEL text
    MENU LABEL TérangaOS - Mode texte
    KERNEL /boot/vmlinuz
    APPEND boot=live persistence textonly initrd=/boot/initrd.img quiet
EOF

    # Copier le noyau et initrd vers isolinux aussi
    cp "$ISO_DIR/boot/vmlinuz" "$ISO_DIR/isolinux/" 2>/dev/null || true
    cp "$ISO_DIR/boot/initrd.img" "$ISO_DIR/isolinux/" 2>/dev/null || true
    
    echo "[OK] ISOLINUX configuré"
}

# =============================================================================
# Génération de l'ISO avec xorriso
# =============================================================================
generate_iso() {
    echo "[INFO] Génération de l'ISO..."
    
    ISO_FILE="$TERANGA_DIR/terangaos-1.0-amd64.iso"
    
    if command -v xorriso &> /dev/null; then
        xorriso -as mkisofs \
            -iso-level 3 \
            -full-iso9660-filenames \
            -volid "TERANGAOS1" \
            -appid "TérangaOS 1.0" \
            -publisher "TérangaOS Team" \
            -preparer "TérangaOS Build System" \
            -eltorito-boot isolinux/isolinux.bin \
            -eltorito-catalog isolinux/boot.cat \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
            -eltorito-alt-boot \
            -e boot/grub/efi.img \
            -no-emul-boot \
            -isohybrid-gpt-basdat \
            -output "$ISO_FILE" \
            "$ISO_DIR"
    elif command -v genisoimage &> /dev/null; then
        genisoimage \
            -o "$ISO_FILE" \
            -b isolinux/isolinux.bin \
            -c isolinux/boot.cat \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            -eltorito-boot isolinux/isolinux.bin \
            -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin \
            -volid "TERANGAOS1" \
            "$ISO_DIR"
    elif command -v mkisofs &> /dev/null; then
        mkisofs \
            -o "$ISO_FILE" \
            -b isolinux/isolinux.bin \
            -c isolinux/boot.cat \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            -volid "TERANGAOS1" \
            "$ISO_DIR"
    else
        echo "[ERROR] Aucun outil de création ISO disponible."
        echo "Installez: xorriso, genisoimage, ou cdrtools"
        exit 1
    fi
    
    # Calculer checksum
    sha256sum "$ISO_FILE" > "$ISO_FILE.sha256"
    
    echo ""
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║           ISO TérangaOS créée!                    ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo ""
    echo "  Fichier: $ISO_FILE"
    echo "  Taille: $(du -h "$ISO_FILE" | cut -f1)"
    echo "  SHA256: $(head -c 16 "$ISO_FILE.sha256")"
    echo ""
}

# =============================================================================
# Menu
# =============================================================================
main() {
    case "$1" in
        prepare) prepare_iso_structure ;;
        squash) create_squashfs ;;
        grub) configure_grub ;;
        isolinux) configure_isolinux ;;
        iso) generate_iso ;;
        all)
            prepare_iso_structure
            create_squashfs
            configure_grub
            configure_isolinux
            generate_iso
            ;;
        *) 
            echo "Usage: $0 {prepare|squash|grub|isolinux|iso|all}"
            ;;
    esac
}

main "$@"
