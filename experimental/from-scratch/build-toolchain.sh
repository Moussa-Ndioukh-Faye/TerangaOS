#!/bin/bash
# =============================================================================
# TérangaOS - Construction de la toolchain GCC
# =============================================================================

set -e

TERANGA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TERANGA_DIR/build"
TC_DIR="$BUILD_DIR/toolchain"
SOURCES_DIR="$BUILD_DIR/sources"

source "$BUILD_DIR/config.sh" 2>/dev/null || true

echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║    TérangaOS - Construction de la Toolchain     ║"
echo "  ╚══════════════════════════════════════════════════╝"

# =============================================================================
# Compilation de GCC (Bootstrap)
# =============================================================================
build_gcc() {
    echo "[1/4] Préparation GCC..."

    GCC_SRC="$TERANGA_DIR/gcc-master/gcc-master"
    GCC_BUILD="$BUILD_DIR/gcc-build"
    
    mkdir -p "$GCC_BUILD"
    cd "$GCC_BUILD"
    
    # Configuration
    "$GCC_SRC/configure" \
        --prefix="$TC_DIR" \
        --target="$CROSS_COMPILE" \
        --with-sysroot="$BUILD_DIR/rootfs" \
        --enable-languages=c,c++ \
        --disable-multilib \
        --disable-nls \
        --disable-shared \
        --enable-threads=posix \
        --with-newlib \
        --without-headers \
        --with-gnu-as \
        --with-gnu-ld
    
    echo "[2/4] Compilation de GCC (cela peut prendre longtemps)..."
    make -j$(nproc) all-gcc || make -j4 all-gcc
    
    echo "[3/4] Compilation des bibliothèques GCC..."
    make -j$(nproc) all-target-libgcc || make -j4 all-target-libgcc
    
    echo "[4/4] Installation de la toolchain..."
    make install-gcc install-target-libgcc
    
    echo "[OK] Toolchain GCC installée dans $TC_DIR"
}

# =============================================================================
# Compilation de glibc
# =============================================================================
build_glibc() {
    echo "[1/3] Préparation glibc..."
    
    GLIBC_SRC="$TERANGA_DIR/glibc"
    GLIBC_BUILD="$BUILD_DIR/glibc-build"
    
    mkdir -p "$GLIBC_BUILD"
    cd "$GLIBC_BUILD"
    
    # S'assurer que les headers Linux sont disponibles
    LINUX_INCLUDE="$BUILD_DIR/rootfs/usr/include"
    mkdir -p "$LINUX_INCLUDE"
    cp -r "$TERANGA_DIR/linux-master/linux-master/include/"* "$LINUX_INCLUDE/" 2>/dev/null || true
    
    # Configuration
    "$GLIBC_SRC/configure" \
        --prefix="$BUILD_DIR/rootfs" \
        --host="$CROSS_COMPILE" \
        --with-headers="$LINUX_INCLUDE" \
        --enable-kernel=5.15 \
        --disable-werror \
        libc_cv_forced_unwind=yes
    
    echo "[2/3] Compilation glibc..."
    make -j$(nproc) || make -j4
    
    echo "[3/3] Installation glibc..."
    make install || sudo make install
    
    echo "[OK] glibc installé"
}

# =============================================================================
# Compilation de Linux Headers
# =============================================================================
build_linux_headers() {
    echo "[1/2] Compilation des headers Linux..."
    
    LINUX_SRC="$TERANGA_DIR/linux-master/linux-master"
    
    cd "$LINUX_SRC"
    
    make ARCH="$ARCH" \
         CROSS_COMPILE="$CROSS_COMPILE" \
         INSTALL_HDR_PATH="$BUILD_DIR/rootfs/usr" \
         headers_install
    
    echo "[OK] Headers Linux installés"
}

# =============================================================================
# Menu
# =============================================================================
main() {
    case "$1" in
        gcc) build_gcc ;;
        headers) build_linux_headers ;;
        libc) build_glibc ;;
        all)
            build_linux_headers
            build_gcc
            build_glibc
            ;;
        *) 
            echo "Usage: $0 {gcc|headers|libc|all}"
            echo ""
            echo "Étapes:"
            echo "  1. headers - Installer les headers Linux"
            echo "  2. gcc     - Compiler GCC"
            echo "  3. libc    - Compiler glibc"
            echo "  4. all     - Tout compiler"
            ;;
    esac
}

main "$@"
