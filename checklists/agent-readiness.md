# Agent Readiness Checklist

Is your environment actually ready for productive agentic AI work? Run through this checklist on a project before you start a serious agent session.

## Project-level setup

- [ ] **`CLAUDE.md` exists** at the project root, with:
  - [ ] Project conventions (test command, build command, lint command)
  - [ ] Stack notes (language, frameworks, key libraries)
  - [ ] Any agent-specific instructions ("use uv for Python deps", "always run tests after edits")
  - [ ] What NOT to do (don't auto-commit, don't touch `prod-config.yaml`, etc.)
- [ ] **`README.md` exists** for humans (separate from CLAUDE.md)
- [ ] **`Makefile` or `justfile`** with standard targets: `setup`, `dev`, `test`, `lint`, `format`
- [ ] **`.env.example`** with required env vars (no real secrets)
- [ ] **`.gitignore`** excludes secrets, build artifacts, `node_modules/`, `.venv/`
- [ ] **Project's runtime versions pinned** in `.mise.toml` (or `.tool-versions`)

## MCP / tool access

- [ ] **Project's `.mcp.json`** lists MCP servers needed (or your global registration covers them)
- [ ] **Required external tools installed** (gh, docker, kubectl, etc.)
- [ ] **Cloud auth set up** if the project uses cloud APIs
- [ ] **API keys in `.env`** (or password manager + symlinked into `.env`)

## Repository hygiene

- [ ] **`.gitattributes`** specifies line endings (`* text=auto eol=lf`)
- [ ] **No uncommitted local changes** before starting (clean `git status`)
- [ ] **On a feature branch**, not main, if the agent will be making changes
- [ ] **CI is passing** on current main (so you have a known-good baseline)

## Verification

- [ ] **Tests pass before agent starts:** `make test` (or equivalent) returns 0
- [ ] **Lint passes:** `make lint`
- [ ] **Build works:** `make build`
- [ ] **Project starts up:** `make dev` (or equivalent) launches without errors
- [ ] **Agent can read the spine:** open Claude Code, ask "what does this project do?" — agent's answer should match your understanding

If any of these fail, fix before starting agent work. Starting on a broken baseline means you can't tell whether the agent broke things or they were already broken.

## Boundaries

- [ ] **Sandboxing posture decided:**
  - **Read-only:** agent reads files but doesn't modify (lowest blast radius)
  - **Edit local:** agent edits files but you commit manually
  - **Edit + commit:** agent commits to a feature branch (NOT main)
  - **Edit + commit + push:** agent pushes to remote (rare; high stakes)
- [ ] **No production credentials** loaded in this environment (use a separate dev/test profile)
- [ ] **Destructive operations gated:** agent shouldn't be able to `rm -rf`, `git push --force`, drop database tables, etc., without explicit permission

## Observability

- [ ] **You'll know when the agent runs.** Either watching live, or a clear notification mechanism (toast, Slack, email)
- [ ] **You can review what changed.** A clear git diff at session end; not 30 commits across 50 files
- [ ] **Cost is bounded.** A token budget for this session is implicit (your patience) or explicit (cost cap)

## Resume / continuity

- [ ] **Agent can resume the session.** If interrupted, you can pick up where it left off (Claude Code's `--continue` flag works)
- [ ] **Project state is checkpoint-able.** You can `git stash` mid-session and unstash later
- [ ] **No mid-session secrets.** All credentials needed for the session are in place at start

## Anti-readiness signs

If any of these are true, your environment is NOT ready:

- ❌ You haven't read the project's CLAUDE.md yourself
- ❌ Tests are failing on main and you don't know why
- ❌ You're working on main directly (not a branch)
- ❌ Production credentials are in your shell environment
- ❌ The project has no `.mise.toml` and you're using whatever Python happens to be on PATH
- ❌ MCP servers aren't registered for tools the agent will obviously need
- ❌ You're starting on a Friday afternoon for a weekend run with no monitoring

## Quick start template

For a new project, the minimum viable agentic setup:

```bash
# In the project directory
cd <project>

# Create CLAUDE.md if missing (start with the project README; iterate)
test -f CLAUDE.md || cp README.md CLAUDE.md
$EDITOR CLAUDE.md   # add agent-specific notes

# Create or activate environment
mise install
test -f .env || cp .env.example .env
$EDITOR .env   # add real API keys

# Verify baseline
make test
make lint
make dev   # in another terminal, verify it starts

# Now start an agent session
claude
```

If any of those steps fail, fix them first.

## What this checklist isn't

- Not a substitute for understanding what the agent will do
- Not a one-time setup; re-verify each session if the project's been idle
- Not exhaustive (your project may have specific readiness checks worth adding)

The goal is "no surprises" — not at the agent layer, not at the env layer, not at the credential layer. Surprises in agentic work compound; checklist them out.
