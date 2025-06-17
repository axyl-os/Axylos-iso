# Using Nix and Guix on AxylOS

AxylOS comes with built-in support for both the Nix and Guix package managers, giving you access to thousands of additional packages beyond what's available in the Arch repositories.

## Nix Package Manager

### Initial Setup

1. Run the setup script as root:
   ```bash
   sudo setup-nix-complete
   ```

2. After installation, either restart your terminal or source the Nix environment:
   ```bash
   source /etc/profile.d/nix.sh
   ```

### Basic Usage

- Install packages:
  ```bash
  nix-env -iA nixpkgs.<package-name>
  ```

- Search for packages:
  ```bash
  nix search nixpkgs <search-term>
  ```

- Update packages:
  ```bash
  nix-channel --update
  nix-env -u
  ```

- Remove packages:
  ```bash
  nix-env -e <package-name>
  ```

### Using Nix Flakes

Nix Flakes are enabled by default. To use them:

```bash
# Create a new flake
mkdir my-project && cd my-project
nix flake init

# Run a package from a flake
nix run nixpkgs#hello

# Develop in a flake environment
nix develop
```

## Guix Package Manager

### Initial Setup

1. Run the setup script as root:
   ```bash
   sudo setup-guix-complete
   ```

2. After installation, either restart your terminal or source the Guix environment:
   ```bash
   source /etc/profile.d/guix.sh
   ```

### Basic Usage

- Install packages:
  ```bash
  guix install <package-name>
  ```

- Search for packages:
  ```bash
  guix search <search-term>
  ```

- Update packages:
  ```bash
  guix pull
  guix package -u
  ```

- Remove packages:
  ```bash
  guix remove <package-name>
  ```

### Create Reproducible Environments

```bash
# Create a manifest file
cat > manifest.scm << EOF
(specifications->manifest
 '("gcc-toolchain"
   "make"
   "python"))
EOF

# Use the manifest to create an environment
guix shell -m manifest.scm
```

## Additional Resources

### Nix

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [NixOS Wiki](https://nixos.wiki/)

### Guix

- [Guix Manual](https://guix.gnu.org/manual/)
- [Guix Cookbook](https://guix.gnu.org/cookbook/en/)
- [Guix Reference](https://guix.gnu.org/manual/en/guix.html#Invoking-guix-package)

## Troubleshooting

If you encounter issues with either package manager:

- Check that the respective daemon is running:
  ```bash
  systemctl status nix-daemon.service
  systemctl status guix-daemon.service
  ```

- Restart the daemons if necessary:
  ```bash
  sudo systemctl restart nix-daemon.service
  sudo systemctl restart guix-daemon.service
  ```

- Ensure your environment variables are set correctly by sourcing the appropriate profile script.

For further assistance, refer to the official documentation or the AxylOS community forums.