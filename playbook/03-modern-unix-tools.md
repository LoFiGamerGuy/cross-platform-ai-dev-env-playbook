# 03 — Modern Unix Tools

The classic Unix utilities (`grep`, `find`, `cat`, `ls`, `top`) have modern replacements that are faster, prettier, and produce output that LLMs (and humans) can read more easily. Worth swapping the defaults.

## The lineup

| Replaces | Tool | Why this one |
|----------|------|--------------|
| `grep` | **ripgrep (`rg`)** | Respects `.gitignore`; columnar `file:line:match` output; ~5-10x faster |
| `find` | **fd** | Sane defaults, `.gitignore`-aware, ~10x faster |
| `cat` | **bat** | Syntax highlighting, line numbers, paging, git diff markers |
| `ls` | **eza** | Colors, icons, git status integration, tree view |
| `diff` (git) | **delta** | Side-by-side, syntax-highlighted; plugs into `git diff`, `git show`, `git log -p` |
| `top` / `htop` | **btm (bottom)** | Cross-platform, composable panes |
| `du` | **dust** | Visual treemap output, human-readable by default |
| `man` | **tldr** | Community-maintained practical examples; faster than reading man pages |
| `make` | **just** | Simpler syntax, no tab-sensitivity bugs, per-project justfiles |
| `cd` | **zoxide** | Frecency-based directory jumping (`z partial-name` instead of `cd ../../...`) |
| Ctrl-R history search | **atuin** | Cross-machine sync, structured storage, queryable as a database |

Plus the foundation:

- **fzf** — fuzzy finder. Wires into shell history, file search, git operations. Composable primitive.

## Install

### macOS

```bash
brew install ripgrep fd bat eza git-delta bottom dust tldr just zoxide atuin fzf
```

### Linux (Ubuntu/Debian)

```bash
# Most are in apt; some are not (use cargo / direct download for those)
sudo apt install ripgrep fd-find bat fzf
# bat installs as 'batcat' on Ubuntu — alias to 'bat'
echo "alias bat='batcat'" >> ~/.bashrc
echo "alias fd='fdfind'" >> ~/.bashrc

# eza: install via cargo or download from releases
cargo install eza
# Or:
# wget https://github.com/eza-community/eza/releases/latest/download/...

# delta, just, zoxide, atuin: install via cargo or download binary
cargo install git-delta just zoxide atuin
```

### Windows (PowerShell or WSL)

In WSL: same as Linux above.

In Windows native via Scoop:
```powershell
scoop install ripgrep fd bat eza delta bottom dust tealdeer just zoxide atuin fzf
```

## Why these matter for agentic AI work

Beyond the personal productivity gains, these tools produce output that's better-shaped for agent consumption:

- **`rg` returns `file:line:match` columnar format.** LLMs parse this far more reliably than `grep`'s variable-width output.
- **`fd` respects `.gitignore`.** Agents searching your project don't waste tokens on `node_modules/` or `.git/`.
- **`bat`'s syntax highlighting helps when piping into agent contexts** (Claude Code shows the highlighted output, which improves readability of file dumps).
- **Structured tools (`gh --json`, `mise registry --json`, `jq`) produce machine-readable output.** When a tool offers JSON output, prefer it for agent contexts.
- **`atuin`'s structured history** lets you query "what did I run on this project last week" as a database, not a flat file.

## Configuration

### fzf integration

Add to your shell rc (after the basic install):

```bash
# Wire fzf into Ctrl-R (history search), Ctrl-T (file search), Alt-C (cd)
eval "$(fzf --bash)"   # or 'fzf --zsh' for zsh
```

### zoxide

```bash
# Replace cd with z (alias provided)
eval "$(zoxide init bash --cmd cd)"   # makes 'cd' use zoxide; original cd is 'builtin cd'
```

After a few days of `cd`-ing around, `cd <partial>` jumps to your most-frecent matching directory. Game-changer for project navigation.

### atuin

```bash
# Wire atuin into Ctrl-R
eval "$(atuin init bash)"

# Sync history across machines (optional, requires registration):
atuin register -u <username> -e <email>
atuin import auto    # imports your existing bash/zsh history
atuin sync
```

After setup, Ctrl-R brings up an interactive history search across all your machines.

### bat

Set as default pager:
```bash
export PAGER='bat --plain --paging=always'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

### delta

Add to `~/.gitconfig`:
```ini
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    line-numbers = true
    side-by-side = true

[merge]
    conflictstyle = diff3
```

## fzf-based interactive widgets

Once fzf is installed, build interactive widgets for common operations. The pattern: any command that emits line-delimited text can be made interactive in ~10 lines of shell.

Useful widgets:

```bash
# Git branch picker with commit-log preview
gbp() {
    local branch
    branch=$(git branch --all | grep -v HEAD | sed 's/^..//' | \
        fzf --preview 'git log --oneline --graph --color=always {1} | head -50') || return
    git checkout "${branch##*/}"
}

# Process killer
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    [ -n "$pid" ] && kill -${1:-9} $pid
}

# Docker container picker (exec into running container)
dexec() {
    local cid
    cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')
    [ -n "$cid" ] && docker exec -it "$cid" /bin/bash
}

# GitHub PR picker (requires gh CLI)
ghpr() {
    local pr
    pr=$(gh pr list --json number,title,author --jq '.[] | "\(.number)\t\(.title) (@\(.author.login))"' | \
        fzf -d $'\t' --with-nth=2 | cut -f1)
    [ -n "$pr" ] && gh pr checkout "$pr"
}
```

Drop these in `~/.config/shell/widgets.sh`. The pattern generalizes: pipe data → fzf → action.

## Anti-patterns

### Aliasing every command

Every alias is a hidden contract. Aliases break scripts that don't source `.bashrc`. Aliases break agent-invoked commands. Alias *sparingly*; prefer functions or scripts in `~/bin/`.

### Loading everything eagerly

Atuin, direnv, navi, mise — each adds shell-init time. If startup feels slow, lazy-load:

```bash
# Lazy-load atuin (only initialize on first Ctrl-R press)
_atuin_lazy_init() {
    eval "$(atuin init bash)"
    bind -x '"\C-r": __atuin_history'
}
bind -x '"\C-r": _atuin_lazy_init; __atuin_history'
```

### Replacing tools that don't have replacements

Some classic Unix tools (`awk`, `sed`, `xargs`) don't have meaningful "modern" replacements. They're already optimal for their use cases. Don't search for replacements that don't exist; learn the originals.

## Next

[Chapter 04: Runtime version management](./04-runtime-version-management.md) — one tool to manage Python, Node, Go, Ruby versions per-project.

---

*Snapshot: May 2026.*
