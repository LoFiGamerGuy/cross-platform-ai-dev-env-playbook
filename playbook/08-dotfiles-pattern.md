# 08 — The Dotfiles Pattern

The single most important parity tool: a version-controlled dotfiles repo with an idempotent installer. Every machine starts from the repo. Every config update is a commit. Every fresh machine setup is a `git clone` + `./install.sh`.

This chapter covers the structure, the installer pattern, and the discipline that keeps the repo healthy.

## Structure

```
~/dotfiles/                              # version-controlled
├── README.md                            # what's in here, how to install
├── install.sh                           # idempotent installer
│
├── shell/
│   ├── bashrc                           # main entry point sourced by ~/.bashrc
│   ├── zshrc                            # main entry point sourced by ~/.zshrc
│   ├── bashrc.d/                        # modular bash config (loaded in order)
│   │   ├── 01-aliases.sh
│   │   ├── 02-fzf.sh
│   │   ├── 03-mise.sh
│   │   ├── 04-cloud-completions.sh
│   │   └── 05-local.sh.example          # local overrides go here (gitignored)
│   └── functions/                       # shell functions, sourced
│       ├── git-helpers.sh
│       ├── fzf-widgets.sh
│       └── cloud-helpers.sh
│
├── prompt/
│   └── starship.toml                    # cross-shell prompt config
│
├── terminal/
│   ├── wezterm.lua                      # cross-platform terminal emulator
│   ├── windows-terminal.json            # Windows Terminal config
│   └── alacritty.toml                   # if you use alacritty
│
├── multiplexer/
│   ├── tmux.conf
│   └── zellij/
│       └── config.kdl
│
├── tools/
│   ├── mise.toml                        # global runtime defaults
│   ├── direnv.toml
│   ├── git/
│   │   ├── gitconfig
│   │   ├── gitignore_global
│   │   └── gitattributes_global
│   ├── ssh/
│   │   └── config                       # NOT keys; just SSH client config
│   └── npmrc
│
├── editor/
│   ├── vimrc
│   ├── nvim/
│   │   └── init.lua
│   └── vscode/
│       ├── settings.json
│       └── keybindings.json
│
├── agent/
│   ├── claude/
│   │   ├── CLAUDE.md                    # global agent persona
│   │   └── settings.json                # tool permissions, hooks
│   └── cursor/
│       └── settings.json
│
└── platform/
    ├── macos/
    │   ├── defaults.sh                  # macOS defaults write commands
    │   └── homebrew/
    │       └── Brewfile                 # brew bundle file
    ├── linux/
    │   └── apt-packages.txt             # apt install list
    └── windows/
        └── scoop-packages.txt           # scoop install list
```

The structure is opinionated. Copy what fits; trim what doesn't.

## The idempotent installer

The installer should be safe to run repeatedly. The first run creates symlinks and installs packages; subsequent runs verify and update what's already there without breaking anything.

A skeleton `install.sh` is in [`examples/install.sh`](../examples/install.sh). Highlights:

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
OS=$(uname -s)

# 1. Detect platform
case "$OS" in
    Darwin)  PLATFORM="macos" ;;
    Linux)   PLATFORM="linux" ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Check for WSL
if [[ "$PLATFORM" == "linux" && -n "${WSL_DISTRO_NAME:-}" ]]; then
    PLATFORM="wsl"
fi

echo "→ Detected platform: $PLATFORM"

# 2. Install platform-specific packages
case "$PLATFORM" in
    macos)
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew bundle --file="$DOTFILES/platform/macos/homebrew/Brewfile"
        ;;
    linux|wsl)
        sudo apt update
        xargs -a "$DOTFILES/platform/linux/apt-packages.txt" sudo apt install -y
        ;;
    windows)
        # Windows: install via scoop
        ;;
esac

# 3. Symlink config files
ln -sf "$DOTFILES/shell/bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES/shell/zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config"
ln -sfn "$DOTFILES/shell/bashrc.d" "$HOME/.config/shell"
ln -sf "$DOTFILES/prompt/starship.toml" "$HOME/.config/starship.toml"
mkdir -p "$HOME/.config/tmux"
ln -sf "$DOTFILES/multiplexer/tmux.conf" "$HOME/.config/tmux/tmux.conf"
ln -sf "$DOTFILES/tools/git/gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/tools/mise.toml" "$HOME/.config/mise/config.toml"
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES/agent/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# 4. Install runtime managers' global versions
if command -v mise &> /dev/null; then
    mise install
fi

# 5. Platform-specific post-install
case "$PLATFORM" in
    macos)
        bash "$DOTFILES/platform/macos/defaults.sh"
        ;;
esac

echo "→ Setup complete. Restart your shell."
```

The `ln -sf` (or `ln -sfn` for directories) is idempotent — running it again doesn't break anything. The package installers (`brew bundle`, `apt install`) are also idempotent.

## Local overrides

You don't want to commit machine-specific config (work email, work cloud project IDs, machine-name-dependent settings). Use a `local` override pattern:

In your `shell/bashrc.d/` loader:

```bash
# Source machine-local overrides last (they win)
[ -r "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"
```

Then `~/.bashrc.local` is gitignored and contains the per-machine overrides:

```bash
# ~/.bashrc.local — gitignored, machine-specific
export AWS_PROFILE=work-account
export GOOGLE_CLOUD_PROJECT=my-work-project
alias work-vpn='sudo openconnect ...'
```

Same pattern for `.gitconfig`:

```ini
# ~/.gitconfig (from dotfiles)
[include]
    path = ~/.gitconfig.local
```

```ini
# ~/.gitconfig.local — gitignored
[user]
    email = me@work.com
    signingkey = ABC123
```

## Discipline

### Test the installer twice a year

Spin up a fresh VM (or container, or rented Linux instance), clone your dotfiles, run the installer, see what fails. Fix the failures. Most parity bugs accumulate here.

### Commit small, often

`git add` and commit each config change as you make it. Don't batch a week's worth of tweaks into one commit. Small commits make it easy to revert specific changes when one breaks something.

### Use branches for risky changes

If you're trying out a new tool or significantly restructuring the dotfiles, branch first:

```bash
cd ~/dotfiles
git checkout -b try-zellij
# make changes, test on this machine
# if it works, merge to main and pull on other machines
# if it breaks, just `git checkout main` and your old config is back
```

### Don't commit secrets

Never put API keys, SSH private keys, or passwords in the dotfiles repo. They go in:
- Environment files like `~/.bashrc.local` (gitignored)
- A password manager (1Password, Bitwarden) for actual secrets
- The platform's secret store (macOS Keychain, Windows Credential Manager)

If you accidentally commit a secret, rotate the secret immediately and use `git filter-branch` or `bfg` to scrub history. Don't just delete the file in a new commit; the secret stays in git history.

### Deprecate cleanly

When you stop using a tool, remove it from the dotfiles repo. Don't leave the config "in case I come back to it." Configs that aren't used rot. Removed configs can always be brought back via git history.

## Public vs private dotfiles

Some developers keep their dotfiles repo public; others keep it private.

**Public is fine if:**
- You've audited for secrets
- You're comfortable having your aliases / preferences public
- You think it might help others

**Private is fine if:**
- You're not sure you've caught all the secrets
- You consider your dev setup competitive intelligence
- You just don't want it public

There's no operational difference. Pick by preference.

## Adoption rhythm

- **Day 1:** copy this structure (or my [`dotfiles`](https://github.com/LoFiGamerGuy/dotfiles) repo as a starting point), commit your existing configs into it
- **Week 1:** write the installer, test on a fresh VM
- **Month 1:** every machine you touch gets the dotfiles installed
- **Quarterly:** trim what's no longer used; refactor what's grown awkward
- **Bi-annually:** test parity by setting up a fresh VM from scratch

Over months, the repo becomes the canonical source of truth for your dev environment. New machines take 30 minutes instead of 2 days.

## Next

[Chapter 09: Troubleshooting](./09-troubleshooting.md) — common failure modes and diagnostic commands.

---

*Snapshot: May 2026.*
