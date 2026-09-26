# Global Agentic Engineering Guidelines (`AGENTS.md` / `CLAUDE.md` / `GEMINI.md`)

## Core Engineering Philosophy

1. **Plan Before Execution (`spec.md` / `docs/plans/`)**:
   - Do not "draw the owl" in a single blind coding pass for non-trivial features.
   - Start with Socratic design refinement (`brainstorming`), clarify requirements, and write a concise specification or implementation plan (`writing-plans`) with exact file paths and verification steps before writing production code.
2. **Engineer the Harness (Deterministic Verification)**:
   - Every change must be verified using fast, automated CLI feedback loops (`just test`, `pytest`, `go test ./...`, `npm test`, linters, or typecheckers).
   - When an agent makes a mistake or hits a repository-specific gotcha, codify the fix in the project's `AGENTS.md` or `Justfile` so the mistake is never repeated.
3. **Evidence Over Claims (`verification-before-completion`)**:
   - Never claim a bug is fixed or a feature works without running the verification command and inspecting its actual output.
   - Enforce RED-GREEN-REFACTOR (`test-driven-development`) whenever adding functionality or fixing bugs.
4. **Isolated Parallel Workspaces (`using-git-worktrees`)**:
   - Prefer isolated Git worktrees (`git worktree`) or Jujutsu changesets (`jj`) when running parallel tasks or experimental spikes so the primary working tree stays clean.

## Preferred Terminal & Developer Tooling

- **Search & Navigation**: Prefer `rg` (`ripgrep`) for content search and `fd` for file discovery over legacy `grep`/`find`.
- **Structured Data**: Use `jq` for JSON and `yq` for YAML inspection and transformation.
- **Python & AI Tooling**: Prefer `uv` (`uv run`, `uv add`, `uvx`) over raw `pip` or manual `virtualenv` activation.
- **Task Runner**: Check for a `Justfile` (`just --list`) or `Makefile` at the repository root before guessing build/test commands.
- **GitHub Workflow**: Use `gh` (`gh pr`, `gh issue`, `gh run`) for pull request, issue, and CI inspection.

## Cloud & AI Forward Deployed Engineering (FDE) Standards

- **Credentials & Security**:
  - Never hardcode API keys, tokens, project IDs, or service account JSON keys in source files or Git history.
  - Prefer Application Default Credentials (`gcloud auth application-default login` / Workload Identity Federation) and secret managers (`sops`, `age`, Cloud Secret Manager).
- **Production-Grade AI Systems**:
  - Structure GenAI / agent code with explicit timeouts, retries, structured outputs (Pydantic / JSON Schema), observability/tracing hooks, and deterministic evaluation harnesses.
  - Separate prompt templates, tool definitions, and orchestration logic cleanly.
