# Contributing

This playbook is opinionated — the picks reflect ~5 years of cross-platform development across Mac, Linux, Windows, WSL, and cloud VMs. Contributions that align with the playbook's discipline are welcome; contributions that fundamentally rework the picks need to argue convincingly.

## What's most welcome

In rough priority order:

1. **Corrections.** Outdated install commands, broken links, deprecated tools.
2. **Platform-specific fixes.** Something that works on Linux but breaks on Windows or vice versa.
3. **War stories.** "I tried this and here's what broke" with the specific failure mode + fix.
4. **New configs in `examples/`.** Reference configs for tools the playbook covers but doesn't ship configs for.
5. **Translations.** README and key docs in other languages.

## What will likely be declined

- **Tool advocacy.** "Use my favorite tool instead" without a reasoned case for why it's better for cross-platform agentic work.
- **GUI-first additions.** The playbook is terminal-first by design.
- **Removing the parity discipline.** The whole point of the playbook is that one setup works everywhere. PRs that add OS-specific divergence as a default need to argue strongly.
- **Adding ceremony.** The playbook tries to be operational, not exhaustive. Adding "best practices" without operational value is friction.

## How to contribute

### For corrections / bug fixes:
1. Open a PR with the fix
2. Note which platform you tested on

### For new content (a new chapter, a new checklist, a new example config):
1. Open an issue first describing what you want to add
2. We'll discuss whether it fits and how it should be scoped
3. Then PR the content

## Style conventions

- **Short sentences.** "X happens because Y" beats "It is the case that X happens, which is attributable to Y."
- **Concrete commands.** When discussing a setup step, show the exact command. Avoid "use your package manager to install X" without naming the actual command.
- **Note the platform.** Where commands differ per OS, label them clearly (`# macOS`, `# Linux/Ubuntu`, `# Windows PowerShell`, `# WSL bash`).
- **Date the snapshot when relevant.** Tool versions and recommendations evolve.
- **No hype.** "Game-changing" — banned.

## Maintainer

Ryan Gosnell — [GitHub @LoFiGamerGuy](https://github.com/LoFiGamerGuy)

---

*This file is CC BY 4.0 licensed, same as the rest of the repo.*
