#!/usr/bin/env bash
# build-aur-packages.sh - Build packages from AUR for AxylOS

set -e

PKGDIR="$(pwd)/aur-packages"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_USER="aur-builder"
NEED_AUTH_USER=0

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Log messages
log() {
  echo -e "${BLUE}[build-aur]${RESET} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

warn() {
  echo -e "${YELLOW}[WARNING]${RESET} $1"
}

error() {
  echo -e "${RED}[ERROR]${RESET} $1" >&2
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  NEED_AUTH_USER=1
  
  # Check if the build user exists
  if ! id -u "$BUILD_USER" &>/dev/null; then
    log "Creating build user '$BUILD_USER'..."
    useradd -m "$BUILD_USER"
    
    # Add to sudoers with NOPASSWD for pacman
    echo "$BUILD_USER ALL=(ALL) NOPASSWD: /usr/bin/pacman" >> /etc/sudoers.d/aur-builder
    chmod 440 /etc/sudoers.d/aur-builder
  fi
fi

# Create package directory if it doesn't exist
mkdir -p "$PKGDIR"
chown -R "$BUILD_USER":"$BUILD_USER" "$PKGDIR" || true

# Install required packages
log "Installing required packages..."
pacman -S --needed --noconfirm base-devel git paru

# Function to build AUR package
build_package() {
  local pkg="$1"
  
  log "Building AUR package: $pkg"
  
  if [ "$NEED_AUTH_USER" -eq 1 ]; then
    # Run as build user if we're root
    cd "$PKGDIR"
    su -c "cd '$PKGDIR' && paru -S --needed --noconfirm $pkg" - "$BUILD_USER"
  else
    # Run directly if we're already a non-root user
    cd "$PKGDIR"
    paru -S --needed --noconfirm "$pkg"
  fi
}

# Build and install Nix
build_package "nix"
success "Nix package built and installed successfully!"

# Build and install Guix and dependencies
log "Building Guix dependencies..."
# List of required packages for Guix
GUIX_DEPS=(
  "guile-avahi"
  "guile-gcrypt"
  "guile-git-lib"
  "guile-gnutls"
  "guile-json"
  "guile-lzlib"
  "guile-lzma"
  "guile-sqlite3"
  "guile-zlib"
  "guile-ssh"
  "guile-semver"
  "guile-lib"
  "disarchive"
)

for dep in "${GUIX_DEPS[@]}"; do
  build_package "$dep"
done

# Build and install Guix
build_package "guix"
success "Guix package built and installed successfully!"

# Create packages archive for later inclusion in ISO
log "Creating AUR packages archive..."
PKG_CACHE="/var/cache/pacman/pkg"
AUR_PKGS_TAR="$SCRIPT_DIR/aur-packages.tar.zst"

# Find all installed Nix and Guix related packages
find "$PKG_CACHE" -name "nix-*.pkg.*" -o -name "guix-*.pkg.*" -o -name "guile-*.pkg.*" -o -name "disarchive-*.pkg.*" -print0 | \
  xargs -0 tar -cf "$AUR_PKGS_TAR" --zstd

success "AUR packages archive created at: $AUR_PKGS_TAR"
log "This archive can now be included in the AxylOS ISO and installed during setup."