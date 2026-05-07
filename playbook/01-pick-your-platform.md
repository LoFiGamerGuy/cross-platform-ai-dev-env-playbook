# 01 — Pick Your Platform

Before any tool installs, decide your *primary* platform. The playbook supports cross-platform parity, but every developer has a primary OS where they spend 80%+ of their work. The choice shapes everything else.

## The three viable choices

### macOS (recommended for most)

**Why it's the default for AI engineering work:**
- Unix-like by default; no WSL layer needed
- Best terminal emulator support (iTerm2, WezTerm)
- All Anthropic / OpenAI SDKs developed and tested on Mac first
- Hardware: Apple Silicon GPUs handle local model inference reasonably; same machine handles dev + light local LLM
- Homebrew package manager is mature and reliable

**Where it falls short:**
- Hardware cost (M4 Max MacBook Pro = $3K+)
- Limited GPU options for serious local model work (need cloud or Linux box)
- Some Linux-specific tools have different flags (`brew install coreutils` if you want GNU versions)

**Pick macOS as primary if:** you're a working developer who wants minimal OS friction, you're already in Apple's ecosystem, your AI workloads are mostly hosted (not local).

### Linux (Ubuntu / Fedora / Arch)

**Why it's the natural fit for serious AI work:**
- Native everything; no compatibility layers
- Best GPU support (CUDA on NVIDIA hardware, ROCm on AMD)
- Cloud VMs are Linux; local Linux means dev/prod parity
- Strong package management (apt, dnf, pacman); no third-party manager needed

**Where it falls short:**
- Hardware procurement is harder (good Linux laptops exist but are niche)
- Suspend/resume, audio, Bluetooth still occasionally fragile depending on distro + hardware
- Some commercial tools (Slack, Notion, Adobe) have lesser-quality Linux clients

**Pick Linux as primary if:** you're doing serious local model work, you want dev/prod parity with Linux servers, you're comfortable with the hardware-pickiness tradeoff.

### Windows + WSL2

**Why it's underrated:**
- Best gaming + work hybrid (WSL2 gives you a real Linux environment for dev work; Windows handles GUI apps and games)
- WSL2 = full Ubuntu (or Debian, Fedora, Arch) running on a Linux kernel under Hyper-V
- Many gaming-focused users already have powerful Windows hardware that's wasted on dev-only Linux
- Pricing: same hardware as a high-end gaming PC, plus a real Linux dev environment, vs a $3K+ MacBook Pro

**Where it falls short:**
- Two layers (Windows + WSL2) means two configs, two file systems, two networking layers
- Filesystem performance: stuff inside WSL is fast; stuff in `/mnt/c/` (Windows side) is slow
- Cross-OS file ops can produce CRLF / encoding gotchas
- WSL2 doesn't have direct GPU passthrough by default; CUDA-in-WSL2 works but adds setup complexity

**Pick Windows + WSL2 as primary if:** you already have powerful Windows hardware, you want a single machine for both gaming and serious dev work, you're willing to accept the two-layer complexity for the cost savings.

## What I'd actually recommend

For most readers of this playbook (developers building agentic AI applications), in priority order:

1. **macOS** if budget allows and you don't need local GPU work — minimum friction, maximum tool compatibility
2. **Linux** if you're doing serious local model inference / training, or you want dev/prod parity with Linux servers
3. **Windows + WSL2** if you have Windows hardware already and don't want to dual-boot or buy a Mac

You're not choosing forever. You can switch. But pick one as your *primary* — the playbook's parity discipline assumes you have a primary that you treat as the source of truth, and the other machines (cloud VMs, secondary laptops) sync to it.

## Multi-machine setup

Most working developers have ≥2 machines (laptop + desktop, or laptop + cloud VM). The playbook's parity discipline (chapter 05) is the answer.

Common combinations:

| Primary | Secondary | Common pattern |
|---------|-----------|----------------|
| Mac (laptop) | Linux cloud VM | Code on Mac, deploy/run on Linux |
| Mac (laptop) | Mac (desktop) | Same OS, sync via dotfiles repo |
| Linux (workstation) | Linux laptop | Same OS, sync via dotfiles repo |
| Windows + WSL2 (desktop) | WSL2 laptop | WSL2 on both, sync via dotfiles repo |
| Windows + WSL2 (desktop) | Mac (laptop) | Two primaries; treat as separate setups with parallel dotfiles |

The "two primaries" case (e.g., gaming-PC at home + Mac at work) is workable but doubles your maintenance load. Consider whether you actually need both.

## What you do NOT need

- **Dual-boot Windows/Linux.** WSL2 is good enough for ~95% of cases. Dual-boot is for the remaining 5% who need bare-metal Linux performance.
- **Three OSes.** If you're already running Mac + Linux + Windows, you're spending more time maintaining environments than working in them. Pick two.
- **Custom Linux distro.** Ubuntu, Fedora, or Debian. Don't optimize the OS underneath your dev environment; you're optimizing the wrong thing.
- **WSL1.** WSL2 is years old now. WSL1 is deprecated for new setups.

## Decision time

If you've been agonizing over the choice, default to macOS. If you've been on Windows for years and don't want to switch, set up WSL2 today. If you're already happy on Linux, stay there.

Once you've decided, [chapter 02](./02-shell-prompt-multiplexer.md) is next.

---

*Snapshot: May 2026. Hardware and OS recommendations evolve.*
