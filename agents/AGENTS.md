# Global Agentic Engineering Guidelines (`AGENTS.md` / `CLAUDE.md` / `GEMINI.md`)

## Core Engineering Philosophy

1. **Plan Before Execution (`spec.md` / `docs/plans/`)**:
   - Do not "draw the owl" in a single blind coding pass for non-trivial features.
   - Start with Socratic design refinement (`brainstorming`), clarify requirements, and write a concise specification or implementation plan (`writing-plans`) with exact file paths and verification steps before writing production code.
2. **Engineer the Harness (Deterministic Verification)**:
   - Every change must be verified using fast, automated CLI feedback loops (`just quick`, `just test`, `just premerge`, `pytest`, `go test ./...`, `npm test`, linters, or typecheckers).
   - When an agent makes a mistake or hits a repository-specific gotcha, codify the fix in the project's `AGENTS.md` or `Justfile` so the mistake is never repeated.
3. **Evidence Over Claims (`verification-before-completion`)**:
   - Never claim a bug is fixed or a feature works without running the verification command and inspecting its actual output.
   - Enforce RED-GREEN-REFACTOR (`test-driven-development`) whenever adding functionality or fixing bugs.
4. **Isolated Parallel Workspaces (`using-git-worktrees`)**:
   - Use one Git worktree per concurrent agent or experimental spike (`git worktree add`, or the harness's native worktree mode) so the primary working tree stays clean. Never share a working tree between agents.
   - If you find changes in the working tree that you did not make, assume another agent or the human made them: leave them alone and stay within your task's scope.
5. **Agent Review Before Human Review**:
   - Before declaring a task done, review your own diff with fresh eyes (`git diff`), as if a different engineer wrote it.
   - Explicitly flag any newly added dependency, removed or weakened test, and any change outside the task's scope.

## Tests & Verification Rules

- Start every session by running the fast test tier (`just quick`, or `just test` if there is no `quick` recipe) so you know the baseline before changing anything.
- Reproduce a bug (ideally with a failing test) before fixing it.
- The only thing worse than a failing test is a reduction in test coverage. Never delete, skip, or weaken a test to make a suite pass; fix the code or report the conflict.
- Prefer quiet test output (`-q`) to save context; rerun verbosely only for the failures you are investigating.

## Git Hygiene

- Commit in small, focused, reviewable steps with clear messages; do not fold unrelated edits into one commit.
- Never add AI co-author or session trailers (`Co-Authored-By`, `Claude-Session`, `Assisted-by`) or override `git user.name` / `user.email` with an agent identity.
- Never run history-destroying commands (`git reset --hard`, `git checkout -- .`, `git clean -fd`, `git push --force`, `git stash drop`) without explicit human approval.
- Never commit secrets or local environment files (`.env`, `.env.*`, `.envrc`). Check `git status` before every commit.

## Long Sessions & Handoffs

- After context compaction, re-read the active spec in `docs/plans/` and this file before continuing.
- **Land the plane** at the end of a session: record remaining work (issues or the spec's task list), run all verification gates, commit, and write a short handoff note (what changed, what is left, how to verify).

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
