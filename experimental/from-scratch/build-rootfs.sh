#!/bin/bash
# =============================================================================
# TérangaOS - Construction du RootFS (Système de fichiers racine)
# =============================================================================

set -e

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TERANGA_DIR/build"
ROOTFS="$BUILD_DIR/rootfs"

source "$BUILD_DIR/config.sh" 2>/dev/null || true

echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         TérangaOS - Construction du RootFS     ║"
echo "  ╚══════════════════════════════════════════════════╝"

# =============================================================================
# Création de la structure de base
# =============================================================================
create_base_structure() {
    echo "[INFO] Création de la structure de base..."
    
    mkdir -p "$ROOTFS"/{bin,boot,dev,etc/{conf.d,init.d,rc.d,run},home,lib,lib64,media,mnt,opt,proc,root,sbin,srv,sys,tmp,usr/{bin,lib,share,src},var/{cache,lib,log,run,spool}}
    
    # Liens symboliques
    ln -sf lib "$ROOTFS/lib64" 2>/dev/null || true
    ln -sf usr/bin "$ROOTFS/bin" 2>/dev/null || true
    ln -sf usr/lib "$ROOTFS/lib" 2>/dev/null || true
    ln -sf usr/sbin "$ROOTFS/sbin" 2>/dev/null || true
    
    # Permissions
    chmod 1777 "$ROOTFS/tmp"
    chmod 700 "$ROOTFS/root"
    
    echo "[OK] Structure de base créée"
}

# =============================================================================
# Installation de BusyBox
# =============================================================================
install_busybox() {
    echo "[INFO] Compilation et installation de BusyBox..."
    
    BB_SRC="$TERANGA_DIR/busybox"
    BB_BUILD="$BUILD_DIR/busybox-build"
    
    mkdir -p "$BB_BUILD"
    cd "$BB_BUILD"
    
    # Configuration statique pour simplicité
    "$BB_SRC/configure" \
        --prefix="$ROOTFS" \
        --enable-static \
        --disable-shared \
        --config /etc/busybox.conf || \
    make defconfig
    
    make -j$(nproc)
    make CONFIG_PREFIX="$ROOTFS" install
    
    echo "[OK] BusyBox installé"
}

# =============================================================================
# Installation des utilitaires GNU
# =============================================================================
install_coreutils() {
    echo "[INFO] Installation des GNU Coreutils..."
    
    CU_SRC="$TERANGA_DIR/coreutils"
    CU_BUILD="$BUILD_DIR/coreutils-build"
    
    mkdir -p "$CU_BUILD"
    cd "$CU_BUILD"
    
    "$CU_SRC/configure" \
        --prefix="$ROOTFS/usr" \
        --enable-install-program=hostname \
        --with-packager="TérangaOS" \
        --disable-nls
    
    make -j$(nproc)
    make install
    
    # Copier les liens symboliques
    cd "$ROOTFS/usr/bin"
    for util in cat chgrp chmod chown cp date dd df echo false hostname ln ls mkdir mknod mv pwd rm rmdir sleep stty su true uname; do
        [ -f "$util" ] || ln -sf ../bin/coreutils/$util $util 2>/dev/null || true
    done
    
    echo "[OK] Coreutils installé"
}

# =============================================================================
# Installation de Bash
# =============================================================================
install_bash() {
    echo "[INFO] Installation de Bash..."
    
    BASH_SRC="$TERANGA_DIR/gnu_bash-master/gnu_bash-master"
    BASH_BUILD="$BUILD_DIR/bash-build"
    
    mkdir -p "$BASH_BUILD"
    cd "$BASH_BUILD"
    
    "$BASH_SRC/configure" \
        --prefix="$ROOTFS/usr" \
        --disable-nls \
        --without-bash-malloc \
        --with-installed-readline
    
    make -j$(nproc)
    make install
    
    # Remplacer sh
    ln -sf bash "$ROOTFS/bin/sh"
    ln -sf bash "$ROOTFS/usr/bin/sh"
    
    echo "[OK] Bash installé"
}

# =============================================================================
# Installation de OpenRC
# =============================================================================
install_openrc() {
    echo "[INFO] Installation de OpenRC..."
    
    ORC_SRC="$TERANGA_DIR/openrc"
    
    cd "$ORC_SRC"
    
    # Compiler et installer OpenRC
    meson setup build --prefix="$ROOTFS/usr" --sysconfdir="$ROOTFS/etc"
    meson install -C build
    
    # Copier les scripts depuis le template
    cp -r "$TERANGA_DIR/rootfs/etc/"* "$ROOTFS/etc/" 2>/dev/null || true
    
    echo "[OK] OpenRC installé"
}

# =============================================================================
# Installation de ncurses
# =============================================================================
install_ncurses() {
    echo "[INFO] Installation de ncurses..."
    
    NC_SRC="$TERANGA_DIR/ncurses"
    NC_BUILD="$BUILD_DIR/ncurses-build"
    
    mkdir -p "$NC_BUILD"
    cd "$NC_BUILD"
    
    "$NC_SRC/configure" \
        --prefix="$ROOTFS/usr" \
        --with-shared \
        --without-ada \
        --enable-widec \
        --without-tests
    
    make -j$(nproc)
    make install
    
    # Créer les liens non-widec
    for lib in ncurses form panel menu; do
        ln -sf lib${lib}w.so "$ROOTFS/usr/lib/lib${lib}.so" 2>/dev/null || true
    done
    
    echo "[OK] ncurses installé"
}

# =============================================================================
# Configuration du système
# =============================================================================
configure_system() {
    echo "[INFO] Configuration du système..."
    
    # Hostname
    echo "terangaos" > "$ROOTFS/etc/hostname"
    echo "127.0.1.1 terangaos" >> "$ROOTFS/etc/hosts"
    
    # Fstab
    cat > "$ROOTFS/etc/fstab" << 'EOF'
# /etc/fstab - TérangaOS
UUID=ROOT_UUID    /               ext4    defaults    0 1
UUID=BOOT_UUID    /boot           ext2    defaults    0 2
proc              /proc           proc    defaults    0 0
sysfs             /sys            sysfs   defaults    0 0
devtmpfs          /dev            devtmpfs defaults   0 0
tmpfs             /tmp            tmpfs   defaults    0 0
tmpfs             /run            tmpfs   mode=0755   0 0
EOF

    # Inittab
    cat > "$ROOTFS/etc/inittab" << 'EOF'
::sysinit:/sbin/openrc sysinit
::wait:/sbin/openrc boot
::wait:/sbin/openrc default
tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/openrc shutdown
EOF

    # OS Release
    cat > "$ROOTFS/etc/os-release" << 'EOF'
NAME="TérangaOS"
VERSION="1.0 (Djolof)"
ID=terangaos
PRETTY_NAME="TérangaOS 1.0 (Djolof)"
VERSION_ID="1.0"
EOF

    # Profil
    cat > "$ROOTFS/etc/profile" << 'EOF'
export PATH=/usr/bin:/bin:/usr/local/bin:/sbin:/usr/sbin
export TERM=xterm-256color
alias ll='ls -la'
PS1='\[\033[01;32m\]\u@terangaos\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

    echo "[OK] Système configuré"
}

# =============================================================================
# Installation du kernel
# =============================================================================
install_kernel_modules() {
    echo "[INFO] Installation des modules noyau..."
    
    if [ -d "$BUILD_DIR/rootfs/lib/modules" ]; then
        cp -r "$BUILD_DIR/rootfs/lib/modules/"* "$ROOTFS/lib/modules/" 2>/dev/null || true
    fi
    
    # Copier le noyau
    if [ -f "$BUILD_DIR/rootfs/boot/vmlinuz-terangaos" ]; then
        mkdir -p "$ROOTFS/boot"
        cp "$BUILD_DIR/rootfs/boot/vmlinuz-terangaos" "$ROOTFS/boot/"
        cp "$BUILD_DIR/rootfs/boot/System.map-terangaos" "$ROOTFS/boot/" 2>/dev/null || true
    fi
    
    echo "[OK] Modules installés"
}

# =============================================================================
# Création de l'initramfs
# =============================================================================
create_initramfs() {
    echo "[INFO] Création de l'initramfs..."
    
    if [ -x "$(command -v dracut)" ]; then
        dracut --force \
               --hostonly \
               --no-hostonly-cmdline \
               "$BUILD_DIR/images/initramfs-terangaos.img" \
               5.15.0-terangaos
    else
        # Initramfs basique avec BusyBox
        mkdir -p "$BUILD_DIR/initramfs"/{bin,dev,etc,lib,mnt/root,proc,root,sbin,sys,usr/bin,usr/sbin}
        
        # Copier BusyBox
        cp "$ROOTFS/bin/busybox" "$BUILD_DIR/initramfs/bin/"
        
        # Créer les liens
        cd "$BUILD_DIR/initramfs/bin"
        for applet in sh ash ash; do
            ln -sf busybox $applet 2>/dev/null || true
        done
        for applet in mount umount switch_root reboot sleep echo cat grep init; do
            ln -sf busybox $applet 2>/dev/null || true
        done
        
        # Script init
        cat > "$BUILD_DIR/initramfs/init" << 'EOF'
#!/bin/busybox sh
/bin/busybox --install -s
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo "TérangaOS booting..."
exec switch_root /mnt/root /sbin/init
EOF
        chmod +x "$BUILD_DIR/initramfs/init"
        
        # Créer l'archive
        cd "$BUILD_DIR/initramfs"
        find . -print0 | cpio --null -ov --format=newc | gzip -9 > "$BUILD_DIR/images/initramfs-terangaos.img"
    fi
    
    echo "[OK] Initramfs créé"
}

# =============================================================================
# Menu
# =============================================================================
main() {
    mkdir -p "$BUILD_DIR/images"
    
    case "$1" in
        base) create_base_structure ;;
        busybox) install_busybox ;;
        coreutils) install_coreutils ;;
        bash) install_bash ;;
        openrc) install_openrc ;;
        ncurses) install_ncurses ;;
        kernel) install_kernel_modules ;;
        initramfs) create_initramfs ;;
        configure) configure_system ;;
        all)
            create_base_structure
            configure_system
            # Les suivants nécessitent un système Linux avec compilation
            echo "[WARN] Les étapes suivantes nécessitent un système Linux:"
            echo "       busybox, coreutils, bash, openrc, ncurses"
            echo "       Exécutez: build-rootfs.sh <component>"
            ;;
        *) 
            echo "Usage: $0 {base|busybox|coreutils|bash|openrc|ncurses|kernel|initramfs|configure|all}"
            ;;
    esac
}

main "$@"
