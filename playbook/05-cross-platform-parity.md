# 05 — Cross-Platform Parity

The discipline that prevents "works on my Mac, breaks on the cloud VM" drift. This chapter covers the failure modes that bite when you work across more than one OS, and the patterns that prevent them.

## The principle

**Treat parity as a product, not an aspiration.** A setup with parity is one where:

- The same dotfiles install cleanly on every OS you use
- The same tools are available with the same commands
- The same scripts run with the same behavior
- An agent run on machine A produces the same artifacts as the same run on machine B

If any of those isn't true, you have parity drift, which manifests as silent failures.

## What works the same on every OS (good news)

The modern toolchain is genuinely cross-platform now:

- **ripgrep, fd, bat, eza, delta, fzf, zoxide, atuin, mise, just, lazygit, starship** — all have native binaries for Linux, macOS, and Windows
- **Git** — same on every platform (modulo line-ending defaults; see below)
- **Docker / Podman** — same CLI on every platform
- **Most modern language runtimes** (Node, Python, Go, Rust)
- **MCP servers** — protocol-defined; portable by design

Stick to this layer, and parity comes mostly for free.

## Where parity breaks (and what to do)

### Line endings (CRLF vs LF)

The classic. Windows defaults to CRLF; Mac and Linux to LF. Mismatched line endings cause:

- Shell scripts to fail with cryptic errors (`bad interpreter: /bin/bash^M`)
- Git diffs to show "every line changed" when nothing actually did
- Editor merge conflicts on whitespace

**Fix:**

In your global `.gitconfig`:
```bash
git config --global core.autocrlf input        # Linux/Mac
git config --global core.autocrlf true          # Windows
```

Or, better — add a `.gitattributes` to every repo:

```
* text=auto eol=lf
*.bat text eol=crlf
*.ps1 text eol=crlf
*.sh text eol=lf
*.py text eol=lf
```

Before running an unfamiliar script:
```bash
file script.sh
# If output says "with CRLF line terminators":
dos2unix script.sh
# Or:
sed -i 's/\r$//' script.sh
```

### Path separators

Windows uses `\`; everything else uses `/`. Most modern tools accept both, but not all:

- Bash on Git Bash for Windows accepts `/` for most things
- `mise activate bash` emits Windows-format PATH that Git Bash can't resolve (see chapter 04 for fix)
- Python's `pathlib` handles both (always use `Path` objects, not string concatenation)

**Discipline:**
- In code: always use `pathlib.Path` (Python), `path.join` (Node), or your language's path API. Never string-concat paths.
- In shell scripts: use forward slashes; both Git Bash and POSIX shells accept them.
- For `mise` on Git Bash: shims mode, not activate.

### Font names

Nerd Fonts (used for Powerline glyphs in Starship, multiplexer status bars, etc.) register as abbreviated metadata names — `JetBrainsMono NFM`, not `JetBrainsMono Nerd Font Mono`. Configuring your terminal with the wrong name silently falls back to a system font. Icons disappear without error.

**Fix:**
After installing a Nerd Font, list registered families and use the exact registered name:

```bash
# macOS
fc-list | grep -i nerd

# Linux
fc-list : family | grep -i nerd

# Windows — open Settings → Personalization → Fonts and check the registered name
```

Test by rendering a known glyph (a Powerline arrow). If you see a placeholder square, the font name is wrong.

### Shell defaults

- macOS: zsh
- Linux: bash (usually)
- Windows: PowerShell (Windows-native), bash (Git Bash or WSL)
- Ubuntu's `/bin/sh` is `dash`, not bash — bash-specific syntax silently fails in scripts that use `#!/bin/sh`

**Discipline:**
- Pick one interactive default and configure it the same way on every machine
- For scripts, pin the shell explicitly: `#!/usr/bin/env bash`, not `#!/bin/sh`
- For shell-portable scripts: stick to POSIX features. If you need bash-isms, declare bash explicitly.

### Aliases and functions

A function defined in `.bashrc` exists only in interactive shells that source `.bashrc`. Scripts run with `bash script.sh` don't see it. Agents that invoke shell commands via a harness usually don't see it either.

**Discipline:**
- Don't assume aliases exist in scripts or agent-invoked contexts
- Define commonly-needed functionality as scripts in `~/bin/` or `~/.local/bin/`
- For convenience aliases that help interactive use, alias a script call rather than embedding logic in the alias

### Default tools

`grep` on Mac is BSD grep; on Linux it's GNU grep. Different flag support. Same for `sed`, `date`, `cp`, `tar`, many others.

**Two fixes:**
1. Install GNU coreutils on Mac via Homebrew if you regularly write portable shell:
   ```bash
   brew install coreutils gnu-sed gnu-tar
   ```
2. Or, use modern replacements (`rg`, `fd`, `sd`) — they have the same behavior across platforms (chapter 03).

### Notification / desktop integration

Toast notifications, system tray, file dialogs — platform-specific. A script that uses `osascript` for Mac notifications won't work on Linux.

**Discipline:**
- Wrap platform-specific calls behind a single function (`alert "message"`) that detects platform and dispatches
- For agent-relevant notifications: prefer email/Slack/file-based output that works the same everywhere

## Cloud CLIs

`gcloud`, `aws`, `az` install on every platform, but auth flows differ:

- Mac/Linux: usually browser-based OAuth, credentials in `~/.config/gcloud/` etc.
- Windows: similar but credential storage paths differ
- WSL: separate from Windows; need to auth in WSL specifically

**Discipline:**
- Use environment variables for credentials in scripts (`AWS_PROFILE`, `GOOGLE_APPLICATION_CREDENTIALS`) rather than relying on platform-specific credential stores
- Document the auth setup once per project so a teammate (or agent) on a different OS can replicate it

## The dotfiles repo pattern

The single most important parity tool: a version-controlled dotfiles repo with an idempotent installer. See [chapter 08](./08-dotfiles-pattern.md) for the full pattern.

The short version: you keep all your config in a git repo; an `install.sh` symlinks (or copies) the configs to the right places per OS; a fresh machine takes 30 minutes to set up.

## Test parity twice a year

Set a calendar reminder: every 6 months, intentionally set up a fresh VM (or container) and run your installer. If anything fails, fix the installer. That's where the parity bugs accumulate.

## Agent-specific concerns

Agents introduce a few additional parity considerations:

- **Line endings in agent-edited files.** An agent editing files on Windows may insert CRLF; the same file edited on Mac stays LF. PRs end up with mixed line endings. Fix: enforce via `.gitattributes`.
- **Tool availability in agent environments.** An agent that calls `rg` works on a machine where ripgrep is installed; fails where it isn't. Make required tooling part of the project's setup script.
- **Path resolution in agent shells.** Agent harnesses often invoke commands in non-interactive shells that don't source `.bashrc`. PATH may differ. Use absolute paths in agent-invoked commands when in doubt.
- **Environment variables.** API keys, project IDs, service endpoints — all differ across machines. Use `.env.example` (committed) and `.env` (gitignored) per project so agents find consistent variable names.

## Pragmatic test

If you can do these, your parity is good:

1. Pull your dotfiles repo onto a fresh machine, run the installer, have a working environment in under an hour
2. Move a half-finished agent task from Mac to Windows (or WSL to Linux) without anything breaking
3. Run a script you wrote three months ago on a different machine without modification
4. Have a teammate clone your project and reproduce your dev environment from documentation alone

If any of these fails consistently, you have parity drift worth fixing.

## What to skip

- A unified GUI experience across OSes (terminal-first work is more portable)
- A single config file format (let each tool use its native format; the dotfiles repo abstracts this)
- The exact same theme everywhere (themes are aesthetic; behavior matters more)
- Identical hardware (parity is software discipline; hardware variation is fine)

The goal is *behavioral* parity. Visual parity is a bonus, not the target.

## Next

[Chapter 06: WSL-specific](./06-wsl-specific.md) — patterns and pitfalls when running WSL2 on Windows.

---

*Snapshot: May 2026.*
