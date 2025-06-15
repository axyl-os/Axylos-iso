# Axylos Development Environment

This document describes how to set up and use the Nix-based development environment for Axylos development on NixOS.

## Quick Start

1. **Enter the development environment:**
   ```bash
   nix develop
   ```

2. **Build the ISO:**
   ```bash
   nix run .#build
   # or directly:
   ./build_iso.sh
   ```

3. **Lint shell scripts:**
   ```bash
   nix run .#lint
   ```

4. **Format shell scripts:**
   ```bash
   nix run .#format
   ```

## Prerequisites

- NixOS or Nix package manager installed
- Docker (for containerized builds)
- Sufficient disk space (ISO building requires several GB)

## Development Environment Features

The Nix flake provides a comprehensive development environment with:

### Core Tools
- **Build tools**: gcc, make, cmake, pkg-config
- **Python**: python3, pip, uv, setuptools, pyparted, pydantic
- **Shell tools**: bash, zsh, shellcheck, shfmt
- **Version control**: git, gh, gitui

### Arch Linux Development
- **ISO creation**: cdrtools, squashfs-tools, syslinux
- **Filesystem tools**: dosfstools, mtools, parted, gptfdisk
- **Container tools**: docker, qemu

### Development Utilities
- **Editors**: vim, neovim, nano
- **File tools**: tree, fd, ripgrep, bat, exa
- **System tools**: htop, btop, strace, gdb
- **Archive tools**: unzip, zip, tar, gzip, xz

## Directory Structure

```
axylos-iso/
├── archiso/                 # Archiso configuration
│   ├── airootfs/            # Root filesystem overlay
│   ├── packages.x86_64      # Package list
│   └── profiledef.sh        # Profile definition
├── installation-scripts/    # Build scripts
├── .github/workflows/       # CI/CD workflows
├── build_iso.sh            # Main build script
├── flake.nix               # Nix development environment
├── .envrc                  # Direnv configuration
└── DEVELOPMENT.md          # This file
```

## Building Process

### Local Build
```bash
# Enter development environment
nix develop

# Build ISO
./build_iso.sh
```

### Using Nix Commands
```bash
# Build ISO using Nix
nix run .#build

# Lint all shell scripts
nix run .#lint

# Format all shell scripts
nix run .#format
```

### Docker Build (CI/CD)
```bash
# Build Docker image
nix build .#docker-image

# Load and run
docker load < result
docker run -it axylos-dev:latest
```

## Environment Variables

The development environment sets up several useful variables:

- `PROJECT_ROOT`: Current project directory
- `BUILD_DIR`: Build output directory (`$HOME/Axyl-Build`)
- `OUT_DIR`: ISO output directory (`$HOME/Axyl-Iso`)
- `EDITOR`: Set to neovim
- `PAGER`: Set to bat (with syntax highlighting)

## Useful Aliases

When in the development environment, these aliases are available:

- `ll`: Enhanced directory listing with exa
- `cat`: Syntax-highlighted file viewing with bat
- `find`: Fast file finding with fd
- `grep`: Fast text search with ripgrep

## Development Workflow

### 1. Make Changes
Edit files in the `archiso/` directory:
- `packages.x86_64`: Add/remove packages
- `airootfs/`: Modify root filesystem overlay
- `profiledef.sh`: Update ISO metadata

### 2. Test Build
```bash
# Quick syntax check
shellcheck build_iso.sh

# Test build
./build_iso.sh
```

### 3. Quality Assurance
```bash
# Lint all scripts
nix run .#lint

# Format scripts
nix run .#format

# Run pre-commit hooks
pre-commit run --all-files
```

### 4. Test ISO
- Use QEMU for quick testing:
  ```bash
  qemu-system-x86_64 -cdrom ~/Axyl-Iso/*.iso -m 2048
  ```
- Test on real hardware for final validation

## Customization

### Adding Packages
Edit `archiso/packages.x86_64` and add package names (one per line).

### Custom Configuration
Modify files in `archiso/airootfs/` to customize the live environment.

### Themes and Branding
Update artwork and themes in the appropriate subdirectories.

## Troubleshooting

### Build Failures
1. Check disk space (need 5+ GB free)
2. Verify archiso version compatibility
3. Check package availability in Arch repos
4. Review build logs for specific errors

### Permission Issues
```bash
# Fix ownership if needed
sudo chown -R $USER:$USER ~/Axyl-Build ~/Axyl-Iso
```

### Docker Issues
```bash
# Restart Docker service
sudo systemctl restart docker

# Clean Docker cache
docker system prune -f
```

## CI/CD Integration

The project includes GitHub Actions workflows:

- `build-iso.yaml`: Automated ISO building
- `build-image.yaml`: Docker image creation
- `shellcheck.yml`: Shell script linting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes in the development environment
4. Test thoroughly (lint, format, build)
5. Submit a pull request

## Resources

- [Archiso Documentation](https://wiki.archlinux.org/title/Archiso)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Axylos Official Website](https://axyl.org)
- [Project Repository](https://github.com/awfixers-stuff/axylos-iso)

## Support

- Discord: [Join the community](https://awfixer.link/discord)
- Issues: GitHub Issues tracker
- Documentation: This file and inline comments

---

Happy hacking! 🚀