# 06 — WSL-Specific

WSL2 (Windows Subsystem for Linux v2) is the strongest cross-platform pattern for Windows users. It gives you a real Linux environment on Windows, which means most of the cross-platform pain in chapter 05 disappears if you treat WSL as your primary development environment.

This chapter covers the WSL2 setup that actually works for serious agentic AI engineering, and the pitfalls that come with the two-layer architecture.

## When to use WSL2

**Use WSL2 if:**
- You have Windows hardware you want to keep using for dev work (gaming PC, work laptop)
- You don't want to dual-boot
- You want a real Linux environment without buying a Mac or Linux machine
- You need to test cross-platform behavior (your code runs on a Mac/Linux server in production; you can test on WSL2 locally)

**Skip WSL2 if:**
- You're on a Mac or native Linux already
- You only need light development tooling and Windows-native terminals (PowerShell, Git Bash) are sufficient
- Your hardware doesn't support virtualization or Hyper-V

## Initial setup

### Install WSL2 + Ubuntu

In an admin PowerShell:

```powershell
wsl --install
# Default install gives you Ubuntu LTS. To pick a different distro:
wsl --install -d Ubuntu-24.04
# List available distros:
wsl --list --online
```

Reboot when prompted. On first launch of Ubuntu, set up your username and password (Linux user, separate from your Windows user).

### Verify WSL2 (not WSL1)

```powershell
wsl --list --verbose
# Should show VERSION 2 for your distro. If it says VERSION 1, upgrade:
wsl --set-version Ubuntu 2
```

WSL1 is deprecated; you should be on WSL2.

### Install Windows Terminal

If not already installed:
- Microsoft Store: search "Windows Terminal"
- Or via winget: `winget install Microsoft.WindowsTerminal`

Configure profiles for both PowerShell and your WSL distro. Set WSL bash as the default profile if you'll use it as your primary.

## The two-filesystem rule

This is the single most important WSL2 discipline. WSL2 has two filesystems:

- **Linux filesystem** (`~/`, `/home/<user>/`) — fast, native Linux semantics
- **Windows filesystem mounted at `/mnt/c/`** — slow when accessed from Linux, full Windows semantics

**Discipline:** keep your projects in the Linux filesystem. Always.

```bash
# Good: project lives in Linux filesystem
cd ~/code/my-project

# Bad: project lives on Windows filesystem
cd /mnt/c/Users/me/Documents/my-project   # filesystem ops will be 5-20x slower
```

The slowness on `/mnt/c/` isn't theoretical — it's noticeable. `git status` on a 1000-file repo takes 200ms in `~/code/` and 2-3 seconds in `/mnt/c/`. Compounded over a workday, it's hours of friction.

**Migration:** if you have existing Windows-side projects, move them to `~/code/` in WSL. Edit them via VS Code's Remote-WSL extension if you want a Windows-native editor pointing at Linux files.

## Tooling that bridges Windows ↔ WSL

### Windows Terminal

Already mentioned. Tabs for both PowerShell and WSL bash; switch between them seamlessly.

### VS Code with Remote-WSL extension

VS Code installed on Windows, connected to WSL via the Remote-WSL extension. Files stay in WSL; the editor UI is Windows-native. Best of both worlds for editor-centric work.

```bash
# In WSL bash, in a project directory:
code .
# Opens VS Code on Windows, connected to WSL, viewing the current dir
```

### Cursor / Claude Code in WSL

Both work in WSL. Install in the Linux filesystem like you would on a Mac/Linux machine:

```bash
# Claude Code (in WSL bash)
npm install -g @anthropic-ai/claude-code
```

Run from WSL. Output renders in Windows Terminal if that's your terminal emulator.

### File access from Windows side

Need to open a WSL file from a Windows app? Use the `\\wsl$\Ubuntu\home\<user>\` path in Explorer or any Windows file dialog.

```
\\wsl$\Ubuntu\home\me\code\my-project\
```

Or set up a symbolic link in your Windows user folder if you access it constantly.

## Common pitfalls

### "I installed X but the command isn't found"

Check which environment you installed in. Tools installed on the Windows side don't show up in WSL's PATH by default, and vice versa.

```bash
# In WSL — check Linux PATH
echo $PATH

# To make Windows tools available in WSL (usually unnecessary):
export PATH="$PATH:/mnt/c/Windows/System32"
```

Treat WSL and Windows as separate machines. Install your dev tools in WSL.

### `mise activate bash` emits Windows-format PATH

Already mentioned in chapter 04. In WSL, `mise activate bash` works correctly. The Windows-format PATH issue is specific to Git Bash on Windows-native, not WSL.

### Performance on `/mnt/c/`

Already covered. Don't use `/mnt/c/` for active development; use `~/`.

### Network access

WSL2 runs in a virtualized network namespace. `localhost` from Windows reaches the WSL2 instance (most of the time). `localhost` from WSL2 doesn't always reach Windows-hosted services without configuration.

If a WSL2 service needs to be reached from Windows: just use `localhost:<port>` from Windows.

If a Windows service needs to be reached from WSL2: use the WSL2-specific gateway IP, or run the service as `0.0.0.0` to bind on all interfaces.

### Memory limits

WSL2 by default uses up to 50% of host RAM. For a 32GB Windows machine, WSL2 might consume up to 16GB even when idle (memory-cached operations). To cap:

Create `%UserProfile%\.wslconfig`:
```ini
[wsl2]
memory=8GB
processors=4
```

Then `wsl --shutdown` and restart your WSL distro.

### GPU passthrough for local LLMs

WSL2 supports CUDA via the Windows NVIDIA driver — no separate Linux driver needed. Setup:

1. Install the latest NVIDIA Game Ready or Studio driver on Windows (includes WSL CUDA support)
2. In WSL, install CUDA toolkit:
   ```bash
   sudo apt install cuda-toolkit
   ```
3. Verify:
   ```bash
   nvidia-smi   # Should show your GPU
   ```

GPU-accelerated inference (Ollama, vLLM, llama.cpp) works in WSL2 if the GPU is visible. Performance is close to native Linux.

## File watcher quirks

If you're using tools that watch the filesystem (Vite, webpack dev server, nodemon), they don't always detect changes correctly when files are on `/mnt/c/`. Another reason to keep projects in `~/` (the Linux filesystem) where the inotify subsystem works reliably.

## Backup strategy

Your WSL Linux filesystem is a virtual disk file (`ext4.vhdx`) on the Windows side. Standard Windows backup tools (Time Machine equivalents, OneDrive, etc.) won't backup individual files inside it.

**Strategy:**
- Push code to remote (GitHub, GitLab) regularly
- Use git for version control of dotfiles
- For non-git data, set up `rsync` to a remote (NAS, cloud storage) on a schedule

Don't rely on Windows backup to protect WSL filesystem contents.

## Migrating off WSL2

If you ever switch primary machine to a Mac or Linux box: your dotfiles repo (chapter 08) and properly cross-platform tooling (chapter 03) will mostly Just Work. The WSL-specific configs (Windows Terminal profiles, `.wslconfig`) become irrelevant; everything else carries over.

The whole point of cross-platform parity discipline is that switching primary machines is cheap.

## Next

[Chapter 07: AI tooling layer](./07-ai-tooling-layer.md) — Claude Code, Cursor, MCP servers, and the agentic substrate.

---

*Snapshot: May 2026.*
