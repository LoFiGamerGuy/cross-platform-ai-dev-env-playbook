# Changelog

All notable changes to the playbook.

## [1.0.0] — 2026-05-07

### Added — initial public release
- `README.md` — what the playbook is, who it's for, structure
- `LICENSE` — CC BY 4.0
- `CONTRIBUTING.md`, `CHANGELOG.md`
- 9 playbook chapters in `playbook/`:
  - 01-pick-your-platform
  - 02-shell-prompt-multiplexer
  - 03-modern-unix-tools
  - 04-runtime-version-management
  - 05-cross-platform-parity
  - 06-wsl-specific
  - 07-ai-tooling-layer
  - 08-dotfiles-pattern
  - 09-troubleshooting
- 3 checklists in `checklists/`:
  - fresh-machine-setup
  - parity-audit
  - agent-readiness
- 4 example configs in `examples/`:
  - starship.toml
  - tmux.conf
  - mise.toml
  - install.sh

### Notes
- The picks reflect what works in May 2026. Tool ecosystems shift; re-evaluate annually.
- The playbook complements `share-ai-engineering-patterns` sections 02 and 08. That repo's content is the abstract patterns; this playbook is the concrete how.
