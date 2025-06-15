{
  description = "Axylos development environment - Arch Linux based distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Development shell environment
        devShells.default = pkgs.mkShell {
          name = "axylos-dev";
          
          buildInputs = with pkgs; [
            # Core development tools
            git
            gh
            gitui
            
            # Build tools and compilers
            gcc
            make
            cmake
            pkg-config
            
            # Python development (for archinstall and scripts)
            python3
            python3Packages.pip
            python3Packages.setuptools
            python3Packages.wheel
            python3Packages.build
            python3Packages.pyparted
            python3Packages.pydantic
            uv  # Modern Python package manager
            
            # Shell scripting and utilities
            bash
            zsh
            shellcheck
            shfmt
            
            # Arch Linux specific tools (via pacman-static or similar)
            # Note: These might need to be built or obtained differently on NixOS
            
            # Container and virtualization tools
            docker
            docker-compose
            qemu
            qemu-utils
            
            # ISO creation and filesystem tools
            cdrtools
            squashfs-tools-ng
            dosfstools
            mtools
            syslinux
            
            # Network tools
            wget
            curl
            rsync
            
            # Text editors and IDEs
            vim
            neovim
            nano
            
            # File management
            tree
            fd
            ripgrep
            bat
            exa
            
            # System monitoring and debugging
            htop
            btop
            strace
            gdb
            
            # Archive tools
            unzip
            zip
            tar
            gzip
            xz
            
            # Documentation tools
            pandoc
            
            # Version control helpers
            pre-commit
            
            # Linting and formatting
            yamllint
            
            # Notification tools (for build completion)
            libnotify
            
            # Image manipulation (for ISO artwork)
            imagemagick
            
            # Network debugging
            netcat
            nmap
            
            # File system tools
            parted
            gptfdisk
            
            # Compression tools
            lz4
            zstd
            
            # Build automation
            gnumake
            
            # Package management helpers
            jq  # For JSON parsing in scripts
            yq  # For YAML parsing
            
            # Development utilities
            watchman  # File watching
            entr      # File watching alternative
            
            # Testing utilities
            bats      # Bash testing framework
          ];
          
          shellHook = ''
            echo "🚀 Axylos Development Environment"
            echo "================================="
            echo "Available tools:"
            echo "  • Build: gcc, make, cmake, pkg-config"
            echo "  • Python: python3, pip, uv, setuptools"
            echo "  • Shell: bash, zsh, shellcheck, shfmt"
            echo "  • Containers: docker, qemu"
            echo "  • ISO tools: cdrtools, squashfs-tools, syslinux"
            echo "  • Development: vim, neovim, git, gh"
            echo "  • Utilities: ripgrep, fd, bat, exa, tree"
            echo ""
            echo "💡 Useful commands:"
            echo "  • Build ISO: ./build_iso.sh"
            echo "  • Shell check: shellcheck *.sh"
            echo "  • Format shell: shfmt -w *.sh"
            echo "  • Pre-commit: pre-commit install"
            echo ""
            echo "📁 Project structure:"
            tree -L 2 -a
            echo ""
            
            # Set up development aliases
            alias ll='exa -la'
            alias cat='bat'
            alias find='fd'
            alias grep='rg'
            
            # Set up environment variables for development
            export EDITOR=${pkgs.neovim}/bin/nvim
            export PAGER=${pkgs.bat}/bin/bat
            export SHELL=${pkgs.zsh}/bin/zsh
            
            # Add current directory to PATH for local scripts
            export PATH="$PWD:$PATH"
            
            # Python development setup
            export PYTHONPATH="$PWD:$PYTHONPATH"
            
            # Docker setup (if needed)
            export DOCKER_BUILDKIT=1
            
            echo "Environment ready! Happy coding! 🎉"
          '';
          
          # Environment variables
          NIX_ENFORCE_PURITY = 0;  # Allow impure operations needed for ISO building
        };
        
        # Formatter for nix files
        formatter = pkgs.nixpkgs-fmt;
        
        # Package outputs
        packages = {
          # Docker image for CI/CD
          docker-image = pkgs.dockerTools.buildImage {
            name = "axylos-dev";
            tag = "latest";
            contents = [ pkgs.bash pkgs.coreutils ];
            config = {
              Cmd = [ "${pkgs.bash}/bin/bash" ];
              WorkingDir = "/workspace";
            };
          };
          
          # Shell script linter
          lint-scripts = pkgs.writeShellScriptBin "lint-scripts" ''
            echo "🔍 Linting shell scripts..."
            find . -name "*.sh" -type f -exec shellcheck {} +
            echo "✅ Shell script linting complete!"
          '';
          
          # Format shell scripts
          format-scripts = pkgs.writeShellScriptBin "format-scripts" ''
            echo "🎨 Formatting shell scripts..."
            find . -name "*.sh" -type f -exec shfmt -w {} +
            echo "✅ Shell script formatting complete!"
          '';
          
          # Build helper script
          build-iso = pkgs.writeShellScriptBin "build-iso" ''
            echo "🏗️ Building Axylos ISO..."
            if [ -f "./build_iso.sh" ]; then
              ./build_iso.sh
            else
              echo "❌ build_iso.sh not found in current directory"
              exit 1
            fi
          '';
          
          default = self.packages.${system}.build-iso;
        };
        
        # Development apps
        apps = {
          lint = flake-utils.lib.mkApp {
            drv = self.packages.${system}.lint-scripts;
          };
          
          format = flake-utils.lib.mkApp {
            drv = self.packages.${system}.format-scripts;
          };
          
          build = flake-utils.lib.mkApp {
            drv = self.packages.${system}.build-iso;
          };
          
          default = self.apps.${system}.build;
        };
        
        # Checks for CI
        checks = {
          shell-lint = pkgs.runCommand "shell-lint" {} ''
            ${pkgs.shellcheck}/bin/shellcheck ${./build_iso.sh}
            ${pkgs.shellcheck}/bin/shellcheck ${./installation-scripts/build.sh}
            ${pkgs.shellcheck}/bin/shellcheck ${./installation-scripts/re-build.sh}
            touch $out
          '';
        };
      }
    );
}