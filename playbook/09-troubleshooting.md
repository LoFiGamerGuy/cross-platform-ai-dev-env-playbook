# 09 — Troubleshooting

Common failure modes and diagnostic commands. Bookmark this; you'll come back to it.

## Shell startup is slow

**Symptom:** Each new shell takes 1+ seconds to be ready.

**Diagnose:**

```bash
# Time 10 successive shell starts
for i in {1..10}; do time (bash -i -c exit); done 2>&1 | grep real
```

Healthy: under 200ms total. Over 500ms: something's eagerly loading.

**Common causes:**

1. **mise activate** is slow on cold start. Lazy-load:
   ```bash
   # Only activate in interactive shells
   [[ $- == *i* ]] && eval "$(mise activate bash)"
   ```

2. **atuin / direnv / navi** all initialize on shell start. Lazy-load (see chapter 03).

3. **Many bashrc.d files** loaded eagerly. Audit which ones you actually need.

4. **conda init** is notoriously slow. If installed and not used, remove from `.bashrc`. If used, lazy-load.

**Profile to find the culprit:**

```bash
# Add to top of .bashrc
export PROFILE_STARTUP=1
[[ "$PROFILE_STARTUP" == "1" ]] && PS4='+${BASH_SOURCE[0]}:${LINENO}: ' && set -x

# Add to bottom of .bashrc
[[ "$PROFILE_STARTUP" == "1" ]] && set +x

# Then start a new shell and look for slow lines
```

## Command not found, but it's installed

**Symptom:** `command not found: foo` even though you just installed `foo`.

**Diagnose:**

```bash
# Where is the binary?
which foo                    # tells you what shell sees on PATH
type foo                     # also tells you if it's an alias / function / builtin

# Is it actually installed?
ls -la $(which foo) 2>&1

# What's on your PATH?
echo $PATH | tr ':' '\n'
```

**Common causes:**

1. **Need to restart shell** for the new install to be on PATH
2. **Installed in a different shell environment** (e.g., installed in WSL, looking from Git Bash)
3. **PATH order** — wrong version of the same name resolved first
4. **Symlink target gone** — homebrew uninstall left a dangling link

**Fix:**

```bash
# Force shell to re-read PATH
hash -r

# Reinstall
brew reinstall foo
# or
sudo apt install --reinstall foo
```

## Mise is installed but versions don't activate

**Symptom:** `cd` into a project with `.mise.toml`, but `python --version` shows the system Python.

**Diagnose:**

```bash
mise current
# Should show the activated tools

mise doctor
# Diagnoses common issues
```

**Common causes:**

1. **mise not activated in this shell**
   ```bash
   eval "$(mise activate bash)"
   ```

2. **`.mise.toml` malformed** — check the file syntax

3. **Tool not installed yet:**
   ```bash
   mise install   # installs everything declared in .mise.toml
   ```

4. **PATH precedence** — another version manager (pyenv, nvm) is winning. Remove the other manager's shell hooks from your `.bashrc`.

## Git diff shows "every line changed" but nothing changed

**Symptom:** `git status` shows files as modified, `git diff` shows the entire file as a change. Usually after pulling changes someone else made on a different OS.

**Diagnose:**

```bash
# Check the line endings
file <filename>
# "with CRLF line terminators" → Windows-style
# (no mention) → LF, Unix-style

# Check git's view
git config core.autocrlf
git config core.eol
```

**Fix:**

1. Add a `.gitattributes` to the repo:
   ```
   * text=auto eol=lf
   *.bat text eol=crlf
   *.sh text eol=lf
   ```

2. Renormalize the repo:
   ```bash
   git add --renormalize .
   git commit -m "Normalize line endings"
   ```

3. On Windows, set autocrlf:
   ```bash
   git config --global core.autocrlf true
   ```

## Shell script fails with "bad interpreter: /bin/bash^M"

**Symptom:** Trying to run a `.sh` script and getting that exact error.

**Cause:** CRLF line endings in the shebang line.

**Fix:**

```bash
# Check
file script.sh

# Fix in place
dos2unix script.sh
# Or:
sed -i 's/\r$//' script.sh

# Or convert via tr
tr -d '\r' < script.sh > script.sh.tmp && mv script.sh.tmp script.sh
```

Add `*.sh text eol=lf` to `.gitattributes` to prevent recurrence.

## SSH "Permission denied (publickey)"

**Diagnose:**

```bash
# Verbose SSH connect to see what's happening
ssh -v <host>

# Check your SSH agent has keys loaded
ssh-add -l

# Check the remote's authorized_keys has your public key
ssh <host> "cat ~/.ssh/authorized_keys" | grep -i "$(cat ~/.ssh/id_*.pub | awk '{print $NF}')"
```

**Common causes:**

1. **Wrong key** loaded in agent. Add the right one:
   ```bash
   ssh-add ~/.ssh/<key_name>
   ```

2. **Permissions wrong** on `~/.ssh/`. Should be 700; keys 600:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_*
   chmod 644 ~/.ssh/id_*.pub
   chmod 644 ~/.ssh/known_hosts
   chmod 644 ~/.ssh/config
   ```

3. **Public key not on remote.** Add it:
   ```bash
   ssh-copy-id <host>
   ```

4. **Wrong username.** SSH config can override:
   ```
   # ~/.ssh/config
   Host my-server
       HostName 1.2.3.4
       User ubuntu
       IdentityFile ~/.ssh/my_key
   ```

## ANTHROPIC_API_KEY returns 401 from a Python script

**Symptom:** The Anthropic SDK returns "invalid x-api-key" even though `echo $ANTHROPIC_API_KEY` shows a key that looks correct.

**Cause:** The key is the session-injected OAuth token from a Claude Code shell, not a real direct API key.

**Fix:** Use `python-dotenv` with `override=True` to load a real key from a `.env` file:

```python
from dotenv import load_dotenv
load_dotenv(".env", override=True)   # critical: override=True

import anthropic
client = anthropic.Anthropic()
# Now uses the real key from .env, not the session-injected one
```

Add the real key to `.env`:
```
ANTHROPIC_API_KEY=sk-ant-api03-<your-real-direct-key>
```

Verify with a 30-line auth probe before running expensive scripts.

## WSL2 filesystem operations are slow

**Symptom:** `git status` takes 2+ seconds in a project on `/mnt/c/`. `npm install` takes minutes when it should take seconds.

**Cause:** You're on the Windows side of the filesystem, accessed from Linux. Performance is 5-20x slower.

**Fix:** Move the project to the Linux filesystem:

```bash
# In WSL bash
cp -r /mnt/c/path/to/project ~/code/project
cd ~/code/project
# Now everything's fast
```

If you need to access the project from Windows tools (VS Code, Explorer), they can reach into WSL via `\\wsl$\Ubuntu\home\<user>\code\project\`.

## Font glyphs show as boxes / missing

**Symptom:** Powerline arrows or Nerd Font icons in your prompt show as `□` or `?`.

**Diagnose:**

```bash
# What fonts are registered?
fc-list | grep -i nerd      # Mac/Linux

# What does Starship think it's rendering?
starship explain
```

**Common causes:**

1. **Wrong font name in terminal config.** Nerd Fonts use abbreviated metadata names. Test rendering with a known glyph; if it fails, the font name is wrong.

2. **Nerd Font not installed.** Install:
   ```bash
   # macOS
   brew install --cask font-jetbrains-mono-nerd-font

   # Linux
   # Download from https://www.nerdfonts.com/
   ```

3. **Terminal emulator doesn't support fallback fonts.** Either pick a font that has all needed glyphs, or use a terminal emulator with fallback support (WezTerm, Windows Terminal).

## Mise can't find Python on macOS Apple Silicon

**Symptom:** `mise install python@3.12` fails with build errors.

**Cause:** Python build dependencies aren't available.

**Fix:**

```bash
# Install build deps via Homebrew
brew install openssl readline sqlite3 xz zlib tcl-tk

# Then retry
mise install python@3.12
```

For other build issues, mise typically includes a clear error pointing at the missing dependency. Read the error.

## tmux/zellij theme doesn't propagate to existing panes

**Symptom:** You change your prompt theme; new panes get the new theme but existing panes still show the old one.

**Cause:** Pre-existing panes cached the OSC color escape codes at spawn. Theme changes via OSC don't auto-propagate.

**Fix:** Re-emit the OSC codes to existing panes. Pattern (varies by multiplexer):

```bash
# tmux: re-source theme via send-keys (caveat: unsafe in interactive panes)
# Better: kill and recreate panes after theme change
# Or: use a "themepush" function that targets only shell-prompt panes

themepush() {
    for pane in $(tmux list-panes -a -F '#{pane_id}'); do
        tmux send-keys -t "$pane" '' Enter
        # Implementation depends on your theme system
    done
}
```

The cleanest approach: kill panes after theme change, recreate them. Theme change is rare; pane recreation is cheap.

## Diagnostic command reference

When something's wrong, run these in order:

```bash
# 1. Where am I?
pwd
hostname
uname -a

# 2. What shell?
echo $SHELL
ps -p $$

# 3. What's on PATH?
echo $PATH | tr ':' '\n' | nl

# 4. What's installed?
which <tool>
type <tool>

# 5. What's the actual binary?
ls -la $(which <tool>)
file $(which <tool>)

# 6. Recent shell history (in case I just did something stupid)
history | tail -30
```

Most problems get diagnosed with these six. The rest are usually specific to a tool's own diagnostics (`mise doctor`, `claude doctor`, `git diagnose`).

## Where to ask for help

When this chapter doesn't cover your problem:

1. **Project-specific issues:** the project's GitHub issues
2. **Tool-specific issues:** the tool's GitHub issues (most modern tools are open-source)
3. **General WSL issues:** `r/wsl` on Reddit, the WSL GitHub issues
4. **Cross-platform shell scripting:** `shellcheck` (lints for portability), `r/commandline`

For the playbook itself: open an issue on this repo. War stories of "I hit X, here's what fixed it" are welcome contributions (see `CONTRIBUTING.md`).

---

*Snapshot: May 2026. Troubleshooting evolves; this chapter will too.*
