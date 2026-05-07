# 02 — Shell, Prompt, Multiplexer

The three load-bearing layers. Configure these once and you'll be productive immediately. Skip them or do them poorly and you'll fight your environment for years.

## Shell

### Pick: **bash** for portability, **zsh** if you're on Mac

**Bash** is the right default everywhere. POSIX-compliant. Available on every Linux server you'll ever SSH into. Scripts written for bash work everywhere.

**Zsh** is the macOS default since Catalina. Slightly nicer interactive experience (better completion, syntax highlighting). Use it if you're Mac-primary and don't write portable scripts often.

**Fish** is user-friendly but non-POSIX. Tempting for new users; trap for script portability. Skip.

**PowerShell** on Windows when you need Windows-native tooling; otherwise WSL bash.

### Setup

```bash
# Linux/Ubuntu — bash is default
sudo apt install bash-completion

# macOS — zsh is default
# Install zsh-autosuggestions and zsh-syntax-highlighting via Homebrew:
brew install zsh-autosuggestions zsh-syntax-highlighting

# Windows — install Git for Windows (which includes Git Bash), or use WSL2 with bash
```

### Add modular config loading

Don't pile everything into a single `.bashrc` / `.zshrc`. Load modular config files from a directory. This makes individual features easy to disable, easy to debug, and easy to share across machines.

In your `.bashrc` (or `.zshrc`):

```bash
# Modular config loader
if [ -d "$HOME/.config/shell" ]; then
    for f in "$HOME/.config/shell"/*.sh; do
        [ -r "$f" ] && source "$f"
    done
    unset f
fi
```

Then put feature files in `~/.config/shell/`:
- `01-aliases.sh`
- `02-fzf.sh`
- `03-mise.sh`
- `04-cloud-completions.sh`
- ... etc.

To disable a feature, rename the file to `*.sh.disabled`. No surgery on `.bashrc`.

## Prompt

### Pick: **Starship**

Single binary. Cross-shell. Cross-platform. Single config file. Reads `.mise.toml`, `.python-version`, git state, cloud contexts without per-shell plugins.

This is the correct answer regardless of OS. There are alternatives (oh-my-zsh themes, Powerline, Pure) — they all have downsides Starship doesn't. Just install Starship.

### Setup

```bash
# All platforms (via official install script)
curl -sS https://starship.rs/install.sh | sh

# macOS via Homebrew
brew install starship

# Add to your shell rc file:
echo 'eval "$(starship init bash)"' >> ~/.bashrc
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

### Configure

A reasonable starting `~/.config/starship.toml` is in [`examples/starship.toml`](../examples/starship.toml). Highlights:

- Show: current directory, git branch, last command status, runtime version (when relevant), cloud context
- Don't show: hostname (you know which machine you're on), full path (too long), random emoji clutter

**Configuration tip:** embed all palette variants inside one `starship.toml` and swap via a `palette =` field. Live theme switching without juggling multiple config files.

## Multiplexer

### Pick: **Zellij** for new setups, **tmux** if you SSH into many remote hosts

**Zellij** has a discoverable UI (status bar shows keybindings), saner defaults, modern config language (KDL). Better first-time experience.

**tmux** is universal. Pre-installed on most Linux servers. Decades-stable. Pick if you SSH into many remote hosts where you can't install your preferred multiplexer.

If you're starting fresh and not heavily SSH-dependent, **Zellij**. If you live on remote servers, **tmux**.

### Setup

```bash
# tmux
sudo apt install tmux        # Linux
brew install tmux            # macOS

# Zellij (single binary; download from GitHub releases or use a package manager)
brew install zellij          # macOS
# Linux: download from https://github.com/zellij-org/zellij/releases
```

Reference `tmux.conf` is in [`examples/tmux.conf`](../examples/tmux.conf). Highlights:

- Mouse mode on (yes really; it doesn't break copy-paste if configured correctly)
- Vi-style copy mode
- Status bar: session name, window list, current pane title, time
- Reasonable session/window/pane keybindings (don't override too much; use the defaults you'll find on every other tmux setup)

### Configure split-pane layouts as one-keystroke macros

The killer feature: a "quad" layout (2×2 panes) you can summon with one keystroke. Same for "triple" (3 vertical panes), "dual" (2 horizontal), etc.

In `~/.tmux.conf`:

```tmux
# Quad layout: 2x2 panes
bind Q split-window -h \; split-window -v \; select-pane -L \; split-window -v \; select-pane -U
```

Setup time: 30 minutes. Payoff: every day for years.

## Common pitfalls

### Theme palette swaps don't propagate to existing panes

When you change a multiplexer's color palette via OSC escape codes, the change applies to *new* panes/windows but not to ones that already exist. The fix is a `themepush` command (or whatever you name it) that re-emits the OSC sequence to all existing panes.

### Shell startup time

A prompt that adds 500ms to shell startup is a tax paid on every command. Measure your shell startup:

```bash
# Time 10 successive shell starts
for i in {1..10}; do time (bash -i -c exit); done 2>&1 | grep real
```

Healthy: under 200ms total per session. Over 500ms: lazy-load heavy initializers (atuin, direnv, navi can all be lazy-loaded; see chapter 03).

### Aliases vs functions

Aliases are simple but limited. Functions are aliases that work everywhere a regular command works (including in scripts that don't source `.bashrc`).

**Convert this:**
```bash
alias mygrep='grep -nC 3'
```

**To this:**
```bash
mygrep() {
    grep -nC 3 "$@"
}
```

The function version: works in scripts you might invoke separately, can be redirected (`mygrep foo > out.txt`), can take complex argument patterns.

## Next

[Chapter 03: Modern Unix tools](./03-modern-unix-tools.md) — install the rust-rewritten classics that make your terminal actually pleasant to use.

---

*Snapshot: May 2026.*
