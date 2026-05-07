# Cross-Platform AI Dev Env Playbook

A concrete, opinionated playbook for setting up a development environment that works the same on Mac, Linux, Windows (via WSL), and cloud VMs — and is productive for **agentic AI engineering** specifically (Claude Code, Cursor, MCP servers, the lot).

This is not "everyone's favorite shell tools" or "yet another dotfiles list." This is the discipline of **parity** — the same setup, the same behavior, the same agent-friendly substrate, on every machine you touch.

## What this is for

You should adopt this playbook if:

- You work across more than one OS (Mac at home + Linux on cloud VMs, Windows laptop with WSL, dev container on a server, etc.)
- You use Claude Code (or another agent harness) heavily and have hit "this worked on my Mac and broke on the cloud VM"
- You've built up bespoke dotfiles over years and they've drifted into a tangle
- You've watched a teammate's environment look completely different from yours and silently produce different agent behavior

You should skip this playbook if:

- You only ever work on one machine, one OS, one shell — your setup can be specific and you don't need the parity discipline
- You're a new developer learning fundamentals — this assumes you already know your way around a terminal
- You're committed to GUI-first IDE work — the playbook is terminal-first; a GUI-first reader will find it overkill

## What the playbook covers

Nine focused chapters in [`playbook/`](./playbook/), three checklists in [`checklists/`](./checklists/), and four reference config files in [`examples/`](./examples/).

```
cross-platform-ai-dev-env-playbook/
├── README.md                              ← you are here
├── LICENSE                                ← CC BY 4.0
├── CONTRIBUTING.md
├── CHANGELOG.md
│
├── playbook/
│   ├── 01-pick-your-platform.md           ← Mac vs Linux vs Windows+WSL — pick one as primary
│   ├── 02-shell-prompt-multiplexer.md     ← bash/zsh + Starship + tmux/Zellij setup
│   ├── 03-modern-unix-tools.md            ← rg, fd, bat, eza, fzf, atuin — install + integrate
│   ├── 04-runtime-version-management.md   ← mise as one-tool-for-all-languages
│   ├── 05-cross-platform-parity.md        ← line endings, paths, fonts, shell defaults, what breaks
│   ├── 06-wsl-specific.md                 ← WSL2 setup, when to use it, common pitfalls
│   ├── 07-ai-tooling-layer.md             ← Claude Code, Cursor, MCP servers, agent-friendly env
│   ├── 08-dotfiles-pattern.md             ← idempotent installer + dotfiles repo structure
│   └── 09-troubleshooting.md              ← common failure modes + diagnostic commands
│
├── checklists/
│   ├── fresh-machine-setup.md             ← step-by-step for a brand-new laptop
│   ├── parity-audit.md                    ← test cross-platform consistency
│   └── agent-readiness.md                 ← is your env ready for agentic work?
│
└── examples/
    ├── starship.toml                      ← reference Starship config
    ├── tmux.conf                          ← reference tmux config
    ├── mise.toml                          ← reference mise project config
    └── install.sh                         ← skeleton idempotent installer
```

## How long this takes

| Phase | Time | What you get |
|-------|------|--------------|
| Read the playbook end-to-end | ~45 min | A decision framework for your specific setup |
| Apply on a fresh machine | 2–3 hours | A working terminal, prompt, multiplexer, modern Unix tools, runtime manager |
| Build out AI tooling layer | 1–2 hours | Claude Code (or your harness) wired up with your MCP servers |
| Get to cross-platform parity | 1–2 days of incremental work | Same setup on every machine; dotfiles repo with idempotent installer |
| Recovery from wiped machine | 30–60 min once dotfiles repo is in place | Back to baseline |

The total upfront investment is real (~1–2 days for a complete setup). The payoff: every subsequent machine setup, every agent run that doesn't fail because of an env quirk, every minute saved by the modern toolchain.

## How this differs from share-ai-engineering-patterns

The [share-ai-engineering-patterns](https://github.com/LoFiGamerGuy/share-ai-engineering-patterns) repo has two relevant sections:

- **Section 02 (Platform)** covers the *abstract patterns* — what an "agentic spine" is, what cross-platform parity means at the principle level
- **Section 08 (Resources)** lists *general recommendations* — which terminal emulator, which multiplexer, which runtime manager

This playbook is the *concrete how* — copy-pasteable configs, walk-throughs, exact commands, common failure modes with diagnoses. Less abstract; more operational.

If you've read sections 02 and 08 of share-ai-engineering-patterns and want to actually *do* the setup, this is where you go.

## Quick start

The fastest path to a working setup:

1. **Read [`playbook/01-pick-your-platform.md`](./playbook/01-pick-your-platform.md)** — decide your primary OS and whether you need WSL
2. **Run through [`checklists/fresh-machine-setup.md`](./checklists/fresh-machine-setup.md)** — step-by-step commands for the bulk of the setup
3. **Read [`playbook/05-cross-platform-parity.md`](./playbook/05-cross-platform-parity.md)** — the discipline that prevents drift
4. **Set up your dotfiles repo** per [`playbook/08-dotfiles-pattern.md`](./playbook/08-dotfiles-pattern.md) — so the next machine takes 30 minutes, not 2 days

If something breaks: [`playbook/09-troubleshooting.md`](./playbook/09-troubleshooting.md).

## Author and license

Written by **Ryan Gosnell** ([@LoFiGamerGuy](https://github.com/LoFiGamerGuy)).

Licensed under [CC BY 4.0](./LICENSE) — share, adapt, build on; just credit the source.

## Related public repos

This playbook is part of a small family of public reference material on agentic engineering. Each has both a source repo and a live site.

- **[share-ai-engineering-patterns](https://github.com/LoFiGamerGuy/share-ai-engineering-patterns)** &middot; [live catalogue →](https://lofigamerguy.github.io/share-ai-engineering-patterns/) — Practitioner's reference for building with AI agents. Sections 02 and 08 cover the abstract patterns this playbook makes operational. CC BY 4.0.
- **[council-of-five](https://github.com/LoFiGamerGuy/council-of-five)** &middot; [live →](https://lofigamerguy.github.io/council-of-five/) — Multi-perspective decision framework. CC BY 4.0.
- **[reference-library-methodology](https://github.com/LoFiGamerGuy/reference-library-methodology)** &middot; [live →](https://lofigamerguy.github.io/reference-library-methodology/) — System for building a queryable, AI-readable technical reference library. MIT.
- **[alpha-reader-toolkit](https://github.com/LoFiGamerGuy/alpha-reader-toolkit)** &middot; [live →](https://lofigamerguy.github.io/alpha-reader-toolkit/) — Pipeline for honest alpha-reader feedback on fiction. MIT.
- **[five-register-design-system](https://github.com/LoFiGamerGuy/five-register-design-system)** &middot; [live gallery →](https://lofigamerguy.github.io/five-register-design-system/) — Design system. MIT.
- **[terminal-stack](https://github.com/LoFiGamerGuy/terminal-stack)** — Opinionated terminal kit for Git Bash on Windows. The Windows-side reference implementation of the patterns in this playbook.
- **[dotfiles](https://github.com/LoFiGamerGuy/dotfiles)** — Personal dotfiles. The cross-platform reference implementation.

---

*Cross-Platform AI Dev Env Playbook · v1.0 · May 2026.*
