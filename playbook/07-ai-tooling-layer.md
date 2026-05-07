# 07 — AI Tooling Layer

The point of the playbook. Once your shell, prompt, multiplexer, modern tools, and runtime managers are in place, you add the AI tooling layer that turns the environment into an agentic dev setup.

This chapter covers what to install and how to wire it together.

## The four layers

```
┌────────────────────────────────────────────────┐
│  Your project                                   │
│  • CLAUDE.md, AGENTS.md (agent context)         │
│  • specs/, scripts/, .mcp.json                  │
└──────────────────┬─────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────┐
│  Agent harness                                  │
│  • Claude Code (CLI, terminal-native)           │
│  • Cursor (IDE, GUI)                            │
│  • Aider, Continue, Zed AI (alternatives)       │
└──────────────────┬─────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────┐
│  MCP servers (tools the agent can use)          │
│  • Filesystem, GitHub, web fetch, custom        │
│  • Each is its own process; harness connects    │
└──────────────────┬─────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────┐
│  Local model runtime (optional)                 │
│  • Ollama (easy)                                │
│  • LM Studio (GUI)                              │
│  • llama.cpp / vLLM (advanced)                  │
└────────────────────────────────────────────────┘
```

Set up bottom-to-top. Local model runtime is optional; everything else is core.

## Layer 1: agent harness

### Pick: **Claude Code** as primary, **Cursor** if you're IDE-first

**Claude Code** — terminal-native, scriptable, MCP-first. Best for:
- Workflows that need real automation (overnight runs, CI integration)
- Heavy multi-file editing where you watch the diff in your editor of choice
- Scripted plus-interactive use

**Cursor** — IDE-native (VS Code fork). Best for:
- Inline code suggestions while you type
- Visual diff acceptance/rejection
- Single-file edits where the agent's reasoning happens beside the code

**Both** is a real option. Many developers use Cursor for editing and Claude Code for architecture/automation work.

### Install

```bash
# Claude Code (cross-platform)
npm install -g @anthropic-ai/claude-code

# Or via Homebrew on Mac
brew install claude-code

# Verify
claude --version
```

For Cursor: download from [cursor.sh](https://cursor.sh).

For other harnesses (Aider, Continue, Zed AI): see [share-ai-engineering-patterns 08-resources/tool-evaluations.md](https://github.com/LoFiGamerGuy/share-ai-engineering-patterns/blob/main/08-resources/tool-evaluations.md) for comparisons.

### Configure

Claude Code has two config layers:

- **Global:** `~/.claude/CLAUDE.md` — your persona, conventions, defaults applied to every session
- **Per-project:** `<project>/CLAUDE.md` — project-specific context, conventions, scripts

The global persona shapes how Claude responds across all projects (your communication style, your engineering baseline). The project-level CLAUDE.md gives project-specific context (build commands, conventions, common patterns).

## Layer 2: MCP servers

MCP (Model Context Protocol) is how agents access tools beyond text. Each MCP server is a process that exposes tools the agent can call.

### Common servers to install

```bash
# Filesystem (built-in to most harnesses; no install needed)

# GitHub
claude mcp add github -- npx @modelcontextprotocol/server-github

# Web search and fetch
claude mcp add web -- npx @modelcontextprotocol/server-fetch

# Postgres / SQLite
claude mcp add postgres -- npx @modelcontextprotocol/server-postgres
```

For more servers: [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)

### Verify

```bash
claude mcp list
```

You should see each registered server. Test in a session:
```
You: list my open GitHub PRs
```

The agent should call the GitHub MCP and return your actual PRs.

### Per-project MCP config

For project-specific MCP servers (your internal tracker, your monitoring, your custom tools), use a `.mcp.json` file in the project root. The harness loads it when you open a session in that directory.

Example `.mcp.json`:
```json
{
  "mcpServers": {
    "internal-tracker": {
      "command": "python",
      "args": ["./scripts/mcp/tracker_server.py"]
    }
  }
}
```

## Layer 3: project context (CLAUDE.md, AGENTS.md, .mcp.json)

For each project the agent will work on, set up the agentic spine:

```
my-project/
├── CLAUDE.md              # primary agent context
├── AGENTS.md              # alternative if you use multiple harnesses
├── README.md              # human-facing intro
├── Makefile               # standard task entry points
├── .env.example           # required env vars (no secrets)
├── .mcp.json              # MCP server config for this project
├── specs/                 # written task descriptions
└── scripts/               # operational scripts
```

See [share-ai-engineering-patterns 02-platform/agentic-os-spine.md](https://github.com/LoFiGamerGuy/share-ai-engineering-patterns/blob/main/02-platform/agentic-os-spine.md) for the full pattern.

For a CLAUDE.md template that's been refined across many projects, see [the example in share-ai-engineering-patterns](https://github.com/LoFiGamerGuy/share-ai-engineering-patterns/blob/main/examples/example-CLAUDE.md).

## Layer 4: local model runtime (optional)

Most readers won't need this. Useful if:
- You're doing high-volume tasks where per-call cost matters
- You're working with sensitive data that shouldn't leave your network
- You're experimenting with model behavior

### Pick: **Ollama** (default), **vLLM** (production scale)

**Ollama** — easiest path. Single command to pull and serve a model. OpenAI-compatible API.

```bash
# Install
curl -fsSL https://ollama.com/install.sh | sh

# Pull a model
ollama pull llama3.2

# Run
ollama run llama3.2
```

The OpenAI-compatible API runs on `http://localhost:11434/v1`. Wire it into your harness if it supports custom endpoints.

**vLLM** — production-scale serving. Use if you need maximum throughput or you're serving multiple users. Setup is heavier; out of scope for this playbook.

**LM Studio** — GUI for local models. Good if you prefer visual model selection over CLI.

See [share-ai-engineering-patterns 05-local-llms](https://github.com/LoFiGamerGuy/share-ai-engineering-patterns/tree/main/05-local-llms) for the deep dive on local LLM patterns.

## Putting it together

A complete agentic setup, top to bottom:

1. **Project setup** (one-time per project, ~30 min): write CLAUDE.md, set up Makefile, register MCP servers in `.mcp.json`
2. **Session start** (every session, ~30 sec): `cd` into project, run `claude` (or open Cursor)
3. **Work**: type prompts, watch the agent edit and run code, review and accept changes
4. **Session end**: commit good changes; let the harness write a session log if useful

The full setup is the difference between an agent that's productive in your project from minute one vs. one that's still figuring out what your project is at minute thirty.

## Anti-patterns

### Skipping CLAUDE.md "I'll just tell the agent what to do each time"

You'll re-explain the project on every session. Time you could spend on actual work, you'll spend on context-setting. Write CLAUDE.md once; reuse forever.

### Installing every MCP server "just in case"

Each MCP server adds tools to the prompt. Too many tools and the model gets confused about which to use. Curate to what the project actually needs.

### Letting the agent run unattended on production credentials

The agent will misuse production credentials. Always. Sandbox aggressively (chapter on sandboxes in share-ai-engineering-patterns 04-automation).

### One global config for all projects

Your global `~/.claude/CLAUDE.md` should be persona + conventions, not project-specific knowledge. Project-specific stuff goes in the project's `CLAUDE.md`.

## Next

[Chapter 08: Dotfiles pattern](./08-dotfiles-pattern.md) — the idempotent installer that makes a fresh machine setup take 30 minutes.

---

*Snapshot: May 2026.*
