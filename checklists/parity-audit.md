# Parity Audit Checklist

Run this checklist on each of your machines (or compare across them) to detect parity drift. Bi-annual cadence is reasonable; more often if you're actively making config changes.

## Setup parity

For each machine, verify:

- [ ] Same OS version (or known acceptable variation)
- [ ] Same shell as default (bash or zsh)
- [ ] Same primary terminal emulator
- [ ] Same prompt (Starship version, same config)
- [ ] Same multiplexer (tmux or zellij)
- [ ] Same modern Unix tools installed (rg, fd, bat, eza, fzf, zoxide, atuin)
- [ ] Same runtime manager (mise) with same global versions

Record any divergence. Some divergence is intentional (e.g., one machine has CUDA + Ollama for local LLM work; others don't). Mark intentional divergences in your dotfiles README so future you understands why they exist.

## Config parity

- [ ] Same `~/.bashrc` entry point (symlinked to dotfiles)
- [ ] Same modular shell config in `~/.config/shell/`
- [ ] Same Starship config (`~/.config/starship.toml`)
- [ ] Same multiplexer config
- [ ] Same `~/.gitconfig` (with machine-specific overrides in `.gitconfig.local`)
- [ ] Same `~/.claude/CLAUDE.md` global agent persona
- [ ] Same `~/.mise.toml` global runtime defaults

Check: each of these is a symlink to the dotfiles repo (not a separate file edited in place).

```bash
# Verify symlink target
readlink -f ~/.bashrc
# Should show ~/dotfiles/shell/bashrc or similar
```

## Behavior parity

Test each of these on each machine; outputs should be equivalent:

- [ ] Shell startup time under 200ms: `for i in {1..10}; do time (bash -i -c exit); done 2>&1 | grep real`
- [ ] `which python` returns the mise-managed Python (after activating in a project with `.mise.toml`)
- [ ] `rg some-known-string` in a known project finds the same hits
- [ ] `git status` in a known project shows the same state (assuming no local changes)
- [ ] `claude` starts up and completes a basic prompt without errors
- [ ] An MCP server you've registered (e.g., github) is callable

## Cross-platform behaviors

- [ ] A shell script with a `#!/usr/bin/env bash` shebang runs successfully on every machine
- [ ] Line endings on a file edited on each machine are LF (or whatever your `.gitattributes` specifies)
- [ ] `cd` into a project with `.mise.toml` activates the right Python/Node/etc.
- [ ] An agent task started on machine A and resumed on machine B (after `git pull`) completes without environment-related failures

## Agent-specific parity

- [ ] Same Claude Code version
- [ ] Same global `CLAUDE.md` persona
- [ ] Same registered MCP servers (`claude mcp list` shows the same servers)
- [ ] Same project-level `.mcp.json` loads correctly
- [ ] An agent task that runs cleanly on machine A also runs cleanly on machine B

## Documentation parity

- [ ] Each machine listed in dotfiles README
- [ ] Machine-specific overrides documented (which `.local` files differ and why)
- [ ] Backup status documented (which machines have which backups)

## What "parity" means in practice

You're not aiming for identical machines (different hardware, different OS versions are fine). You're aiming for:

1. **Same agent behavior** — agents produce equivalent output on equivalent prompts
2. **Same script behavior** — shell scripts run with the same effects
3. **Same recovery time** — fresh setup of any machine takes <1 hour from dotfiles
4. **Same mental model** — your knowledge of "how to do X" works on every machine

If those hold, you have parity. The visual/aesthetic differences don't matter.

## When you find drift

Drift is normal. The audit's job is to surface it before it becomes silent corruption.

When you find drift, two questions:

1. **Is it intentional?** (e.g., one machine has GPU tools the others don't.) Document it.
2. **Is it accidental?** (e.g., one machine has an old version of a tool.) Fix it — usually means re-running the dotfiles installer to bring it up to date.

The audit should take 15-30 minutes per machine. If it takes hours, your dotfiles aren't comprehensive enough — improve them.
