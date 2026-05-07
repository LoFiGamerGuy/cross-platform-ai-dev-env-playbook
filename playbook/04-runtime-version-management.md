# 04 — Runtime Version Management

If you work in more than one language, you need a runtime version manager. Without one, you'll fight Python 3.10-vs-3.11, Node 18-vs-20, the wrong Java for the wrong project. With one, you set a `.tool-versions` or `.mise.toml` per project and the right runtime picks itself up automatically.

## Pick: **mise** (formerly rtx)

One tool. Handles Python, Node, Ruby, Go, Java, Rust toolchains, and 400+ others via plugins. Cross-platform. Modern. Fast.

The alternatives:

- **asdf** — older, plugin-based, stable. Same idea as mise. Pick if you need a plugin mise doesn't have.
- **pyenv + nvm + rbenv + sdkman** — one tool per language. Each adds its own shell hook, its own startup latency. Don't.
- **System packages (`apt install python3-12`)** — works for one version per OS. Doesn't help when you need three Python versions across three projects.
- **conda / pixi** — for data science workflows. Heavier than mise; appropriate when you need bundled scientific packages.

## Install

```bash
# macOS
brew install mise

# Linux
curl https://mise.run | sh
# Or via cargo: cargo install mise

# Windows (in WSL)
curl https://mise.run | sh
```

Activate in your shell:

```bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
# or 'mise activate zsh' for zsh
```

**Caveat for Windows + Git Bash:** `mise activate bash` emits Windows-format PATH that Git Bash can't resolve. Use shims-only mode there:

```bash
# In Git Bash specifically — use shims, not activate
echo 'export PATH="$HOME/.local/share/mise/shims:$PATH"' >> ~/.bashrc
```

## Use

### Per-project: `.mise.toml`

Create `.mise.toml` at the root of any project:

```toml
[tools]
python = "3.12"
node = "22"
go = "1.23"
```

When you `cd` into the project, mise activates those versions. When you `cd` out, it deactivates. No manual `source venv/bin/activate` rituals.

A reasonable reference `.mise.toml` is in [`examples/mise.toml`](../examples/mise.toml).

### Install versions

```bash
# Install everything declared in current dir's .mise.toml
mise install

# Install a specific version explicitly
mise install python@3.13
mise install node@latest

# List what's installed
mise list

# List what's available
mise registry
```

### Globally pin defaults

```bash
# ~/.mise.toml — global defaults when no project-local config applies
mise use --global python@3.12 node@22
```

## Python-specific

For Python, **also install `uv`**:

```bash
# macOS
brew install uv

# Linux/WSL
curl -LsSf https://astral.sh/uv/install.sh | sh
```

`uv` is a much faster replacement for pip + venv + poetry. Use mise to manage Python versions; use uv to manage packages within those versions:

```bash
# Create a uv-managed virtualenv in the current project
uv venv

# Install packages
uv pip install requests pyyaml anthropic

# Or, init a uv-managed project (lockfile + env in one)
uv init
uv add requests pyyaml anthropic
```

The `uv` workflow: ~10x faster than pip, uses lockfiles for reproducibility, handles version resolution properly. The right default for any new Python project in 2026.

## Rust-specific

`mise` doesn't replicate `rustup`'s component management (clippy, rustfmt) or target management (cross-compilation). Keep `rustup` for Rust toolchains:

```bash
# Install rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Use stable
rustup default stable

# Add components
rustup component add clippy rustfmt
```

Don't try to make mise manage Rust. Use both: rustup for Rust, mise for everything else.

## The pattern: project picks its versions

The big win: every project declares its own runtime versions. New contributor (or future-you, or an agent) clones the repo, runs `mise install`, has the right Python/Node/etc. No `.python-version` plus `package.json` engines plus `Gemfile` ruby version juggle. One file (`.mise.toml`), one tool (`mise`).

Combine with `.envrc` (direnv) for per-project env vars:

```bash
# .envrc
export ANTHROPIC_API_KEY=sk-ant-...
export PROJECT_ROOT=$(pwd)
```

Then `direnv allow` once per project, and the env vars activate on `cd`.

## Common pitfalls

### Mise hook doesn't fire

If `cd` into a project doesn't activate the project's mise versions:

```bash
# Check that mise is activated in this shell
which mise
mise --version

# Check that the file is named correctly (.mise.toml, not mise.toml)
ls -la .mise.toml

# Manually activate
mise install
mise current
```

### Multiple version managers fighting

If you've previously installed pyenv / nvm / rbenv, they may be fighting mise. Symptoms: `which python` returns the wrong path; project-local versions don't activate.

Fix: remove the old version managers' shell hooks from your rc files. Mise should be the only version-manager hook.

### Python venv vs mise

mise installs Python. uv (or `python -m venv`) creates virtualenvs *within* a Python version. They're complementary, not competing. The right pattern: mise for the Python version, uv (or venv) for the project's packages.

### Slow startup with many runtime managers

If your shell startup is slow, mise might be checking many runtime versions. You can skip the mise activation in shells that don't need it:

```bash
# In .bashrc — only activate mise in interactive shells
[[ $- == *i* ]] && eval "$(mise activate bash)"
```

## Next

[Chapter 05: Cross-platform parity](./05-cross-platform-parity.md) — the discipline that prevents drift between machines.

---

*Snapshot: May 2026.*
