# Fresh Machine Setup Checklist

Step-by-step for a brand-new laptop or VM. Assumes you've read the playbook chapters; this is the operational sequence.

## Prerequisites

- [ ] OS installed and updated (macOS, Linux distro, or Windows + WSL2)
- [ ] You have admin / sudo access
- [ ] You have your dotfiles repo URL (or are about to create one)
- [ ] You have your API keys / credentials ready (in a password manager, not in cleartext)

## Phase 1: Foundation (~30 min)

### macOS

- [ ] Install Xcode Command Line Tools: `xcode-select --install`
- [ ] Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- [ ] Install git: `brew install git`
- [ ] Set up SSH key for git:
  - [ ] `ssh-keygen -t ed25519 -C "your_email@example.com"`
  - [ ] Add public key to GitHub/GitLab
- [ ] Test: `ssh -T git@github.com`

### Linux (Ubuntu/Debian)

- [ ] Update package list: `sudo apt update && sudo apt upgrade`
- [ ] Install git, build tools: `sudo apt install -y git build-essential curl`
- [ ] Set up SSH key for git (same as macOS above)
- [ ] Test SSH connection

### Windows + WSL2

- [ ] Install WSL2: `wsl --install` (admin PowerShell)
- [ ] Reboot
- [ ] First-launch setup of Ubuntu (set Linux username/password)
- [ ] Install Windows Terminal (Microsoft Store or `winget install Microsoft.WindowsTerminal`)
- [ ] In WSL: `sudo apt update && sudo apt install -y git build-essential curl`
- [ ] Set up SSH key in WSL (NOT in Windows-side Git installation; keep SSH inside WSL)
- [ ] Configure Windows Terminal default profile to WSL Ubuntu

## Phase 2: Clone dotfiles (~5 min)

- [ ] Clone your dotfiles repo to `~/dotfiles`:
      ```bash
      git clone git@github.com:<you>/dotfiles.git ~/dotfiles
      ```
- [ ] Inspect the installer briefly: `cat ~/dotfiles/install.sh`
- [ ] Run the installer: `bash ~/dotfiles/install.sh`
- [ ] Restart shell to pick up new configs: `exec $SHELL`

(If you don't have a dotfiles repo yet, see [chapter 08](../playbook/08-dotfiles-pattern.md) and create one. Then come back here.)

## Phase 3: Modern Unix tooling (~15 min)

If your dotfiles installer didn't already install these:

- [ ] **macOS:** `brew install ripgrep fd bat eza git-delta bottom dust tldr just zoxide atuin fzf starship`
- [ ] **Linux:** `sudo apt install ripgrep fd-find bat fzf` then `cargo install eza git-delta just zoxide atuin starship` (cargo install for those without apt packages)
- [ ] Verify: `rg --version && fd --version && bat --version && eza --version`

## Phase 4: Runtime version management (~10 min)

- [ ] Install mise: `curl https://mise.run | sh`
- [ ] Add to shell rc: `echo 'eval "$(mise activate bash)"' >> ~/.bashrc`
- [ ] Restart shell
- [ ] Install global runtime defaults: `mise use --global python@3.12 node@22`
- [ ] For Python projects: `brew install uv` (Mac) or `curl -LsSf https://astral.sh/uv/install.sh | sh` (Linux)
- [ ] For Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

## Phase 5: AI tooling layer (~20 min)

### Claude Code

- [ ] Install: `npm install -g @anthropic-ai/claude-code` (requires Node from mise)
- [ ] Verify: `claude --version`
- [ ] Authenticate: `claude` (will prompt for login on first run)
- [ ] Configure global persona: ensure `~/.claude/CLAUDE.md` exists (your dotfiles installer should have symlinked it; if not, copy from `~/dotfiles/agent/claude/CLAUDE.md`)

### MCP servers (optional but recommended)

- [ ] GitHub MCP: `claude mcp add github -- npx @modelcontextprotocol/server-github`
- [ ] Web fetch MCP: `claude mcp add web -- npx @modelcontextprotocol/server-fetch`
- [ ] Verify: `claude mcp list`

### Cursor (if using)

- [ ] Download from [cursor.sh](https://cursor.sh)
- [ ] Install
- [ ] Sign in
- [ ] Configure to your liking (settings sync from GitHub if you've used Cursor before)

## Phase 6: Project-specific setup (~5 min per project)

For each project you'll work on:

- [ ] Clone the project: `git clone git@github.com:<org>/<project>.git`
- [ ] Verify project's `.mise.toml` activates: `cd <project> && mise install`
- [ ] Copy `.env.example` to `.env` and populate with real keys
- [ ] Read the project's `CLAUDE.md` to understand conventions
- [ ] If the project has MCP servers in `.mcp.json`, they auto-load when you start Claude in this directory

## Phase 7: Verify (~10 min)

- [ ] Open a fresh shell — startup time under 200ms (`time (bash -i -c exit)`)
- [ ] Prompt renders correctly with all glyphs visible
- [ ] `rg some-string` works in a project directory and respects `.gitignore`
- [ ] `git status` is fast (<200ms in a moderate-size project)
- [ ] `mise current` shows the right runtime versions in a project with `.mise.toml`
- [ ] `claude` starts up; can complete a "say hello" prompt
- [ ] If using WSL: project files are in `~/`, NOT `/mnt/c/`
- [ ] No errors in shell init: `bash -i -c exit 2>&1 | grep -i error`

## Phase 8: Hardening (~30 min)

Defensive setup that prevents future pain:

- [ ] Set up cloud / remote backup of code: GitHub for git repos, plus rsync for non-git data
- [ ] Test the dotfiles installer one more time on a throwaway VM if you have one
- [ ] Document any machine-specific overrides in `~/.bashrc.local` and `~/.gitconfig.local` (gitignored)
- [ ] Add this machine to your dotfiles README (so future you knows which machines exist)

## Total time

For someone who's done this before: ~2 hours.
For someone setting up dotfiles for the first time: 1-2 days.

Once dotfiles are in place, every subsequent machine: 30-60 minutes.

## What to skip

- **Configuring every tool perfectly on day one.** Use defaults; tune as you discover what doesn't fit.
- **Installing every Modern Unix tool from chapter 03.** Install the ones you'll use; add others when needed.
- **Setting up every cloud CLI you might ever use.** Install per project / per need.

The goal is "working environment for productive agentic AI work." Not "perfect environment." Iterate from there.
