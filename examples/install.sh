#!/usr/bin/env bash
# install.sh — idempotent dotfiles installer
#
# Reference skeleton from the cross-platform-ai-dev-env-playbook.
# Copy to your dotfiles repo as install.sh and customize.
#
# Usage:
#   bash ~/dotfiles/install.sh
#
# Safe to re-run. Symlinks are -sf (force overwrite); package installs are
# idempotent for brew/apt.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
OS=$(uname -s)

# ─── Detect platform ────────────────────────────────────────────────────────

case "$OS" in
    Darwin)  PLATFORM="macos" ;;
    Linux)   PLATFORM="linux" ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Detect WSL specifically
if [[ "$PLATFORM" == "linux" && -n "${WSL_DISTRO_NAME:-}" ]]; then
    PLATFORM="wsl"
fi

echo "→ Detected platform: $PLATFORM"

# ─── Helpers ─────────────────────────────────────────────────────────────────

link() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "  linked: $dest → $src"
}

link_dir() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
    echo "  linked dir: $dest → $src"
}

# ─── Phase 1: Platform-specific package installs ─────────────────────────────

echo "→ Phase 1: install packages"

case "$PLATFORM" in
    macos)
        # Install Homebrew if missing
        if ! command -v brew &> /dev/null; then
            echo "  installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Install everything from Brewfile
        if [[ -f "$DOTFILES/platform/macos/Brewfile" ]]; then
            brew bundle --file="$DOTFILES/platform/macos/Brewfile"
        else
            # Fallback: install core tools individually
            brew install git ripgrep fd bat eza fzf zoxide atuin starship mise just gh
        fi
        ;;

    linux|wsl)
        # apt-based install
        if command -v apt &> /dev/null; then
            sudo apt update
            if [[ -f "$DOTFILES/platform/linux/apt-packages.txt" ]]; then
                xargs -a "$DOTFILES/platform/linux/apt-packages.txt" sudo apt install -y
            else
                sudo apt install -y git ripgrep fd-find bat fzf curl build-essential
            fi
        fi

        # Install non-apt tools via curl/cargo
        if ! command -v starship &> /dev/null; then
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
        if ! command -v mise &> /dev/null; then
            curl https://mise.run | sh
        fi
        # Modern tools that aren't always in apt: install via cargo if available
        if command -v cargo &> /dev/null; then
            cargo install eza git-delta zoxide atuin just || true
        fi
        ;;

    windows)
        # Git Bash on Windows native — assume Scoop or similar is set up
        echo "  Windows: install Scoop and required tools manually before re-running"
        ;;
esac

# ─── Phase 2: Symlink configs ────────────────────────────────────────────────

echo "→ Phase 2: symlink configs"

# Shell
link "$DOTFILES/shell/bashrc" "$HOME/.bashrc"
[[ -f "$DOTFILES/shell/zshrc" ]] && link "$DOTFILES/shell/zshrc" "$HOME/.zshrc"
[[ -d "$DOTFILES/shell/bashrc.d" ]] && link_dir "$DOTFILES/shell/bashrc.d" "$HOME/.config/shell"

# Prompt
[[ -f "$DOTFILES/prompt/starship.toml" ]] && link "$DOTFILES/prompt/starship.toml" "$HOME/.config/starship.toml"

# Multiplexer
[[ -f "$DOTFILES/multiplexer/tmux.conf" ]] && link "$DOTFILES/multiplexer/tmux.conf" "$HOME/.config/tmux/tmux.conf"
[[ -d "$DOTFILES/multiplexer/zellij" ]] && link_dir "$DOTFILES/multiplexer/zellij" "$HOME/.config/zellij"

# Git
[[ -f "$DOTFILES/tools/git/gitconfig" ]] && link "$DOTFILES/tools/git/gitconfig" "$HOME/.gitconfig"
[[ -f "$DOTFILES/tools/git/gitignore_global" ]] && link "$DOTFILES/tools/git/gitignore_global" "$HOME/.gitignore_global"
[[ -f "$DOTFILES/tools/git/gitattributes_global" ]] && link "$DOTFILES/tools/git/gitattributes_global" "$HOME/.gitattributes_global"

# Mise global
[[ -f "$DOTFILES/tools/mise.toml" ]] && link "$DOTFILES/tools/mise.toml" "$HOME/.config/mise/config.toml"

# SSH config (NOT keys; just client config)
[[ -f "$DOTFILES/tools/ssh/config" ]] && link "$DOTFILES/tools/ssh/config" "$HOME/.ssh/config"

# Editor
[[ -f "$DOTFILES/editor/vimrc" ]] && link "$DOTFILES/editor/vimrc" "$HOME/.vimrc"
[[ -d "$DOTFILES/editor/nvim" ]] && link_dir "$DOTFILES/editor/nvim" "$HOME/.config/nvim"

# Agent persona
[[ -f "$DOTFILES/agent/claude/CLAUDE.md" ]] && link "$DOTFILES/agent/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
[[ -f "$DOTFILES/agent/claude/settings.json" ]] && link "$DOTFILES/agent/claude/settings.json" "$HOME/.claude/settings.json"

# ─── Phase 3: Runtime versions ───────────────────────────────────────────────

echo "→ Phase 3: install global runtime versions"

if command -v mise &> /dev/null && [[ -f "$HOME/.config/mise/config.toml" ]]; then
    mise install
fi

# ─── Phase 4: Platform-specific post-install ─────────────────────────────────

echo "→ Phase 4: platform-specific post-install"

case "$PLATFORM" in
    macos)
        if [[ -f "$DOTFILES/platform/macos/defaults.sh" ]]; then
            bash "$DOTFILES/platform/macos/defaults.sh"
        fi
        ;;
esac

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo "→ Setup complete."
echo "  Next: restart your shell (exec \$SHELL) or open a new terminal."
echo "  Then: verify with 'starship --version' and 'mise current'."
