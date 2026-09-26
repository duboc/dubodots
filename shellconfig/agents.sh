# ------------------------------------------------------------------------------
# Agentic Development, Mitchell Hashimoto Workflow & Cloud AI FDE Helpers
# ------------------------------------------------------------------------------

# Privacy & Telemetry Opt-Outs for Agentic Harnesses
export SUPERPOWERS_DISABLE_TELEMETRY=1
export DISABLE_TELEMETRY=1
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# ------------------------------------------------------------------------------
# 1. Jujutsu (jj) & Task Runner (just / uv) Shortcuts (Mitchell Hashimoto stack)
# ------------------------------------------------------------------------------
if command -v jj >/dev/null 2>&1; then
    alias js="jj st"
    alias jd="jj desc"
    alias jn="jj new"
    alias jp="jj git push"
    alias jf="jj git fetch"
    alias jl="jj log"
    alias jtug="jj tug"
    alias jretrunk="jj retrunk"
fi

if command -v just >/dev/null 2>&1; then
    alias jx="just"
    alias jls="just --list"
fi

# ------------------------------------------------------------------------------
# 2. Git Worktree Automation for Parallel Coding Agents (obra/superpowers style)
# ------------------------------------------------------------------------------
alias wtlist="git worktree list"

# Create an isolated Git worktree for a feature or background agent task:
# Usage: wta <branch-name> [base-ref]
function wta() {
    if [ -z "$1" ]; then
        echo "Usage: wta <branch-name> [base-ref]"
        return 1
    fi
    local branch="$1"
    local base="${2:-HEAD}"
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        echo "Error: Not inside a git repository."
        return 1
    }
    local repo_name
    repo_name=$(basename "$root")
    local safe_dir="${branch//\//-}"
    local wt_parent
    wt_parent="$(dirname "$root")/${repo_name}-worktrees"
    local wt_path="${wt_parent}/${safe_dir}"

    mkdir -p "$wt_parent"
    if git show-ref --verify --quiet "refs/heads/${branch}"; then
        git worktree add "$wt_path" "$branch" || return 1
    else
        git worktree add -b "$branch" "$wt_path" "$base" || return 1
    fi

    # Copy untracked local environment files (.env, .envrc) if present
    for envfile in .env .env.local .envrc; do
        if [ -f "${root}/${envfile}" ] && [ ! -f "${wt_path}/${envfile}" ]; then
            cp "${root}/${envfile}" "${wt_path}/${envfile}"
        fi
    done

    cd "$wt_path" || return 1
    if command -v direnv >/dev/null 2>&1 && [ -f .envrc ]; then
        direnv allow
    fi
    echo "Switched to isolated worktree: $wt_path ($branch)"
}

# Interactive fzf Git worktree switcher
function wts() {
    if ! command -v fzf >/dev/null 2>&1; then
        git worktree list
        return 0
    fi
    local selected
    selected=$(git worktree list | fzf --height=40% --reverse --prompt="worktree> " \
        --preview 'git -C {1} status -sb && echo "" && git -C {1} log --oneline -n 10' | awk '{print $1}')
    if [ -n "$selected" ]; then
        cd "$selected" || return 1
    fi
}

# Interactive fzf Git worktree remover + prune
function wtrm() {
    local target="$1"
    if [ -z "$target" ] && command -v fzf >/dev/null 2>&1; then
        target=$(git worktree list | sed '1d' | fzf --height=40% --reverse --prompt="remove worktree> " | awk '{print $1}')
    fi
    if [ -n "$target" ]; then
        git worktree remove "$target" && git worktree prune
    fi
}

# ------------------------------------------------------------------------------
# 3. Harness Engineering & Spec-First Scaffolding (Mitchell Hashimoto Step 2 & 5)
# ------------------------------------------------------------------------------

# Create a timestamped specification / implementation plan document:
# Usage: spec_new <feature-slug>
function spec_new() {
    local slug="${1:-feature}"
    local date_str
    date_str=$(date +%Y-%m-%d)
    local plan_dir="docs/plans"
    local spec_file="${plan_dir}/${date_str}-${slug}.md"

    mkdir -p "$plan_dir"
    if [ ! -f "$spec_file" ]; then
        cat <<EOF > "$spec_file"
# Spec & Implementation Plan: ${slug}

**Date:** ${date_str}
**Status:** Draft

## 1. Problem & Goal
- What are we solving and what does success look like?

## 2. Architecture & Constraints
- Key components, data flow, and non-goals (YAGNI).

## 3. Verification Harness
- Exact CLI commands to verify correctness (tests, linters, smoke checks):
  - \`just test\`

## 4. Bite-Sized Tasks (TDD: Red -> Green -> Refactor)
- [ ] Task 1: ...
- [ ] Task 2: ...
EOF
    fi
    echo "Created spec: $spec_file"
    ${EDITOR:-vim} "$spec_file"
}

# Initialize an Agentic Harness (AGENTS.md, CLAUDE.md, GEMINI.md, Justfile, docs/plans/)
function harness_init() {
    mkdir -p docs/plans
    if [ ! -f AGENTS.md ]; then
        cat <<'EOF' > AGENTS.md
# Project Agent Guidelines (`AGENTS.md`)

## Commands & Verification Harness
- **Run tests**: `just test`
- **Lint / Typecheck**: `just lint`
- **Format**: `just fmt`

## Architecture & Conventions
- Follow spec-first development (`docs/plans/`).
- Enforce RED-GREEN-REFACTOR TDD before marking any task complete.
- Update this `AGENTS.md` whenever a tool or workflow gotcha is discovered.
EOF
        echo "Created AGENTS.md"
    fi

    for link in CLAUDE.md GEMINI.md; do
        if [ ! -e "$link" ]; then
            ln -s AGENTS.md "$link"
            echo "Linked $link -> AGENTS.md"
        fi
    done

    if [ ! -f Justfile ] && [ ! -f justfile ]; then
        cat <<'EOF' > Justfile
# Project Verification & Task Harness
set dotenv-load := true

default:
    @just --list

# Run test suite
test:
    @echo "Configure project test command in Justfile"

# Run linters and type checks
lint:
    @echo "Configure project lint command in Justfile"

# Format source files
fmt:
    @echo "Configure project format command in Justfile"
EOF
        echo "Created Justfile"
    fi
}

# ------------------------------------------------------------------------------
# 4. GitHub CLI (gh) Triage & Review Helpers
# ------------------------------------------------------------------------------
function ghprs() {
    if ! command -v gh >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
        echo "Requires gh and fzf."
        return 1
    fi
    local pr
    pr=$(gh pr list --limit 50 | fzf --height=50% --reverse --prompt="PR> " \
        --preview 'gh pr view {1} --comments' | awk '{print $1}')
    if [ -n "$pr" ]; then
        gh pr checkout "$pr"
    fi
}

function ghissues() {
    if ! command -v gh >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
        echo "Requires gh and fzf."
        return 1
    fi
    local issue
    issue=$(gh issue list --limit 50 | fzf --height=50% --reverse --prompt="Issue> " \
        --preview 'gh issue view {1} --comments' | awk '{print $1}')
    if [ -n "$issue" ]; then
        gh issue view "$issue" --comments
    fi
}

# ------------------------------------------------------------------------------
# 5. Cloud & AI Forward Deployed Engineer (AI FDE) Helpers
# ------------------------------------------------------------------------------
alias gtoken="gcloud auth print-access-token"
alias gidtoken="gcloud auth print-identity-token"

# Display current Cloud, Kubernetes & ADC environment summary
function gcpinfo() {
    if ! command -v gcloud >/dev/null 2>&1; then
        echo "gcloud CLI not found."
        return 1
    fi
    local account project region config_name kctx adc_status
    config_name=$(gcloud config configurations list --filter="IS_ACTIVE=true" --format="value(name)" 2>/dev/null)
    account=$(gcloud config get-value account 2>/dev/null)
    project=$(gcloud config get-value project 2>/dev/null)
    region=$(gcloud config get-value compute/region 2>/dev/null)
    kctx=$(kubectl config current-context 2>/dev/null || echo "none")

    if [ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ] && [ -f "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then
        adc_status="env (${GOOGLE_APPLICATION_CREDENTIALS})"
    elif [ -f "$HOME/.config/gcloud/application_default_credentials.json" ]; then
        adc_status="user ADC (~/.config/gcloud/application_default_credentials.json)"
    else
        adc_status="missing (run: gadc)"
    fi

    echo "Config  : ${config_name:-default}"
    echo "Account : ${account:-unset}"
    echo "Project : ${project:-unset}"
    echo "Region  : ${region:-unset}"
    echo "ADC     : ${adc_status}"
    echo "KubeCtx : ${kctx}"
}

# Interactive fzf GCP project switcher
function gprojf() {
    if ! command -v gcloud >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
        echo "Requires gcloud and fzf."
        return 1
    fi
    local proj
    proj=$(gcloud projects list --format="table[no-heading](projectId,name)" | \
        fzf --height=40% --reverse --prompt="GCP Project> " | awk '{print $1}')
    if [ -n "$proj" ]; then
        gcloud config set project "$proj"
    fi
}

# Interactive fzf gcloud configuration switcher
function gctxf() {
    if ! command -v gcloud >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
        echo "Requires gcloud and fzf."
        return 1
    fi
    local cfg
    cfg=$(gcloud config configurations list --format="table[no-heading](name,properties.core.account,properties.core.project)" | \
        fzf --height=40% --reverse --prompt="gcloud config> " | awk '{print $1}')
    if [ -n "$cfg" ]; then
        gcloud config configurations activate "$cfg"
    fi
}

# Quick Vertex AI Gemini REST endpoint smoke test (verifies IAM, ADC/auth, and VPC-SC)
# Usage: vertex_ping [prompt] [model] [location]
function vertex_ping() {
    local prompt="${1:-Respond with OK and the model version.}"
    local model="${2:-gemini-2.5-flash}"
    local location="${3:-${GOOGLE_CLOUD_LOCATION:-us-central1}}"
    local project
    project="${GOOGLE_CLOUD_PROJECT:-$(gcloud config get-value project 2>/dev/null)}"

    if [ -z "$project" ]; then
        echo "Error: No active GCP project set. Run 'gproj <project-id>' or 'gprojf'."
        return 1
    fi

    local token
    token=$(gcloud auth print-access-token 2>/dev/null) || {
        echo "Error: Unable to obtain access token. Run 'gcloud auth login'."
        return 1
    }

    local endpoint="https://${location}-aiplatform.googleapis.com/v1/projects/${project}/locations/${location}/publishers/google/models/${model}:generateContent"
    local payload
    payload=$(jq -n --arg text "$prompt" '{contents: [{role: "user", parts: [{text: $text}]}]}')

    curl -fsSL -X POST "$endpoint" \
        -H "Authorization: Bearer ${token}" \
        -H "Content-Type: application/json" \
        -d "$payload" | jq -r '.candidates[0].content.parts[0].text // .'
}

# Resolve Cloud Run service URL (interactive fzf if service omitted)
function crun_url() {
    local svc="$1"
    local region="${2:-$(gcloud config get-value run/region 2>/dev/null)}"
    if [ -z "$svc" ] && command -v fzf >/dev/null 2>&1; then
        svc=$(gcloud run services list --format="table[no-heading](metadata.name,status.url)" | \
            fzf --height=40% --reverse --prompt="Cloud Run Service> " | awk '{print $1}')
    fi
    if [ -n "$svc" ]; then
        if [ -n "$region" ]; then
            gcloud run services describe "$svc" --region="$region" --format="value(status.url)"
        else
            gcloud run services list --filter="metadata.name=${svc}" --format="value(status.url)" | head -n 1
        fi
    fi
}
