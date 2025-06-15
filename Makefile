# Axylos Development Makefile
# Convenient commands for development workflow

.PHONY: help dev build clean lint format test docker install-deps check

# Default target
help: ## Show this help message
	@echo "Axylos Development Commands"
	@echo "=========================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

dev: ## Enter the Nix development environment
	@echo "🚀 Starting Axylos development environment..."
	nix develop

build: ## Build the Axylos ISO
	@echo "🏗️ Building Axylos ISO..."
	nix run .#build

build-local: ## Build ISO using local script
	@echo "🏗️ Building ISO locally..."
	./build_iso.sh

clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	rm -rf ~/Axyl-Build ~/Axyl-Iso
	sudo rm -rf /tmp/archlive
	docker system prune -f 2>/dev/null || true

lint: ## Lint all shell scripts
	@echo "🔍 Linting shell scripts..."
	nix run .#lint

format: ## Format all shell scripts
	@echo "🎨 Formatting shell scripts..."
	nix run .#format

check: lint ## Run all checks (alias for lint)

test: ## Test the development environment
	@echo "🧪 Testing development environment..."
	nix flake check

docker: ## Build Docker development image
	@echo "🐳 Building Docker image..."
	nix build .#docker-image
	@echo "✅ Docker image built as 'result'"

docker-load: docker ## Build and load Docker image
	@echo "📦 Loading Docker image..."
	docker load < result
	@echo "✅ Docker image 'axylos-dev:latest' ready"

install-deps: ## Install system dependencies (requires sudo)
	@echo "📦 Installing system dependencies..."
	@if command -v pacman >/dev/null 2>&1; then \
		sudo pacman -S --needed archiso git docker; \
	elif command -v apt >/dev/null 2>&1; then \
		sudo apt update && sudo apt install -y git docker.io; \
	elif command -v dnf >/dev/null 2>&1; then \
		sudo dnf install -y git docker; \
	else \
		echo "⚠️ Package manager not recognized. Please install git and docker manually."; \
	fi

setup: ## Initial project setup
	@echo "⚙️ Setting up Axylos development environment..."
	@if command -v direnv >/dev/null 2>&1; then \
		echo "📁 Setting up direnv..."; \
		direnv allow; \
	else \
		echo "💡 Consider installing direnv for automatic environment loading"; \
	fi
	@mkdir -p ~/Axyl-Build ~/Axyl-Iso
	@echo "✅ Setup complete!"

qemu-test: ## Test ISO with QEMU (requires built ISO)
	@echo "🖥️ Testing ISO with QEMU..."
	@ISO_FILE=$$(ls ~/Axyl-Iso/*.iso 2>/dev/null | head -1); \
	if [ -n "$$ISO_FILE" ]; then \
		echo "Testing: $$ISO_FILE"; \
		qemu-system-x86_64 -cdrom "$$ISO_FILE" -m 2048 -enable-kvm || \
		qemu-system-x86_64 -cdrom "$$ISO_FILE" -m 2048; \
	else \
		echo "❌ No ISO file found. Run 'make build' first."; \
		exit 1; \
	fi

status: ## Show project status
	@echo "📊 Axylos Project Status"
	@echo "======================="
	@echo "Project Directory: $(PWD)"
	@echo "Build Directory: ~/Axyl-Build"
	@echo "Output Directory: ~/Axyl-Iso"
	@if [ -d ~/Axyl-Build ]; then echo "✅ Build directory exists"; else echo "❌ Build directory missing"; fi
	@if [ -d ~/Axyl-Iso ]; then echo "✅ Output directory exists"; else echo "❌ Output directory missing"; fi
	@ISO_COUNT=$$(ls ~/Axyl-Iso/*.iso 2>/dev/null | wc -l); \
	echo "📦 ISO files: $$ISO_COUNT"
	@if command -v nix >/dev/null 2>&1; then echo "✅ Nix available"; else echo "❌ Nix not found"; fi
	@if command -v docker >/dev/null 2>&1; then echo "✅ Docker available"; else echo "❌ Docker not found"; fi

watch: ## Watch for changes and rebuild (requires entr)
	@echo "👀 Watching for changes..."
	@if command -v entr >/dev/null 2>&1; then \
		find . -name "*.sh" -o -name "*.x86_64" -o -name "profiledef.sh" | entr -r make build-local; \
	else \
		echo "❌ entr not found. Install it or use 'nix develop' for access to entr."; \
		exit 1; \
	fi

release: ## Prepare for release (lint, format, build, test)
	@echo "🚀 Preparing release..."
	make lint
	make format
	make build
	@echo "✅ Release preparation complete!"

info: ## Show development environment info
	@echo "ℹ️ Development Environment Information"
	@echo "===================================="
	@echo "Nix Flake: $(PWD)/flake.nix"
	@echo "Archiso Config: $(PWD)/archiso/"
	@echo "Build Script: $(PWD)/build_iso.sh"
	@echo ""
	@echo "🔧 Available Tools (in nix develop):"
	@echo "  • Build: gcc, make, cmake"
	@echo "  • Python: python3, pip, uv"
	@echo "  • Shell: bash, zsh, shellcheck"
	@echo "  • Containers: docker, qemu"
	@echo "  • Development: vim, neovim, git"
	@echo "  • Utilities: ripgrep, fd, bat, exa"

# Development shortcuts
iso: build ## Alias for build
rebuild: clean build ## Clean and rebuild
dev-shell: dev ## Alias for dev