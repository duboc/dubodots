#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPERPOWERS_DIR="$HOME/.local/share/superpowers"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"

SETUP_CLAUDE="${INSTALL_CLAUDE:-0}"
SETUP_ANTIGRAVITY="${INSTALL_ANTIGRAVITY:-0}"
UNINSTALL=0

usage() {
    cat <<EOF
Usage: ./setup_agents.sh [options]

Optional setup for AI coding agents and obra/superpowers skills.
Nothing is installed unless at least one target flag is provided.

Options:
  --claude         Install/configure Claude Code (~/.claude + obra/superpowers)
  --antigravity    Configure Antigravity & Gemini CLI (~/.gemini + obra/superpowers)
  --all            Configure both Claude Code and Antigravity/Gemini CLI
  --uninstall      Remove obra/superpowers and agent configurations installed by this script
  -h, --help       Show this help message

Environment variable equivalents:
  INSTALL_CLAUDE=1, INSTALL_ANTIGRAVITY=1, or INSTALL_AGENTS=1
EOF
}

if [ "${INSTALL_AGENTS:-0}" = "1" ]; then
    SETUP_CLAUDE=1
    SETUP_ANTIGRAVITY=1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --claude)
            SETUP_CLAUDE=1
            shift
            ;;
        --antigravity)
            SETUP_ANTIGRAVITY=1
            shift
            ;;
        --all)
            SETUP_CLAUDE=1
            SETUP_ANTIGRAVITY=1
            shift
            ;;
        --uninstall)
            UNINSTALL=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [ "$UNINSTALL" = "1" ]; then
    echo "Removing optional AI agent configurations and obra/superpowers..."
    if command -v agy >/dev/null 2>&1; then
        agy plugin uninstall superpowers 2>/dev/null || true
    fi
    rm -rf "$SUPERPOWERS_DIR" \
           "$HOME/.agents/skills" \
           "$HOME/.gemini/skills" \
           "$HOME/.gemini/GEMINI.md" \
           "$HOME/.gemini/config/plugins/superpowers" \
           "$HOME/.gemini/config/rules/superpowers.md" \
           "$HOME/.gemini/config/rules/global-engineering.md" \
           "$HOME/.gemini/config/skills.json" \
           "$HOME/.claude/skills" \
           "$HOME/.claude/CLAUDE.md"
    echo "Uninstall complete."
    exit 0
fi

if [ "$SETUP_CLAUDE" != "1" ] && [ "$SETUP_ANTIGRAVITY" != "1" ]; then
    usage
    exit 0
fi

# 1. Clone or update obra/superpowers
mkdir -p "$HOME/.local/share"
if [ ! -d "$SUPERPOWERS_DIR/.git" ]; then
    echo "Cloning obra/superpowers into $SUPERPOWERS_DIR..."
    git clone --depth 1 "$SUPERPOWERS_REPO" "$SUPERPOWERS_DIR"
else
    echo "Updating obra/superpowers..."
    git -C "$SUPERPOWERS_DIR" pull --ff-only 2>/dev/null || true
fi

# 2. Optional: Configure Antigravity & Gemini CLI
if [ "$SETUP_ANTIGRAVITY" = "1" ]; then
    echo "Configuring Antigravity & Gemini CLI with obra/superpowers..."
    mkdir -p "$HOME/.agents/skills" "$HOME/.gemini/skills"
    for skill_path in "$SUPERPOWERS_DIR"/skills/*; do
        if [ -d "$skill_path" ]; then
            skill_name=$(basename "$skill_path")
            ln -sfn "$skill_path" "$HOME/.agents/skills/$skill_name"
            ln -sfn "$skill_path" "$HOME/.gemini/skills/$skill_name"
        fi
    done

    mkdir -p "$HOME/.gemini/config/plugins" "$HOME/.gemini/config/rules"

    if command -v agy >/dev/null 2>&1; then
        agy plugin install "$SUPERPOWERS_DIR" 2>/dev/null || true
    fi

    if [ ! -f "$HOME/.gemini/config/plugins/superpowers/plugin.json" ]; then
        mkdir -p "$HOME/.gemini/config/plugins/superpowers"
        cp -R "$SUPERPOWERS_DIR"/. "$HOME/.gemini/config/plugins/superpowers/"
        cat <<'EOF' > "$HOME/.gemini/config/plugins/superpowers/plugin.json"
{
  "name": "superpowers",
  "description": "Core skills library: TDD, debugging, collaboration patterns, and proven techniques",
  "version": "6.4.2"
}
EOF
        if [ -f "$SUPERPOWERS_DIR/hooks/hooks.json" ]; then
            cp "$SUPERPOWERS_DIR/hooks/hooks.json" "$HOME/.gemini/config/plugins/superpowers/hooks.json"
        fi
    fi

    cat <<EOF > "$HOME/.gemini/config/skills.json"
{
  "entries": [
    {
      "path": "~/.local/share/superpowers/skills"
    }
  ]
}
EOF

    cat <<'EOF' > "$HOME/.gemini/config/rules/superpowers.md"
---
trigger: always_on
description: "Bootstrap obra/superpowers skill methodology and tool mappings at session start."
---

@[using-superpowers](~/.local/share/superpowers/skills/using-superpowers/SKILL.md)
@[antigravity-tools](~/.local/share/superpowers/skills/using-superpowers/references/antigravity-tools.md)
EOF

    cat <<'EOF' > "$HOME/.gemini/config/rules/global-engineering.md"
---
trigger: always_on
description: "Global engineering, harness, and Cloud AI FDE guidelines."
---

@[global-agents](~/.dotfiles/agents/AGENTS.md)
EOF

    cat <<'EOF' > "$HOME/.gemini/GEMINI.md"
@~/.local/share/superpowers/skills/using-superpowers/SKILL.md
@~/.local/share/superpowers/skills/using-superpowers/references/gemini-tools.md
@~/.dotfiles/agents/AGENTS.md
EOF
    echo "Antigravity & Gemini CLI configuration complete."
fi

# 3. Optional: Configure Claude Code
if [ "$SETUP_CLAUDE" = "1" ]; then
    echo "Configuring Claude Code (~/.claude) with obra/superpowers..."
    if ! command -v claude >/dev/null 2>&1 && [ "$(uname -s)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
        echo "Installing claude-code via Homebrew Cask..."
        brew install --cask claude-code || echo "Note: Skipping claude-code binary installation; configuring ~/.claude files only."
    fi

    mkdir -p "$HOME/.claude/skills"
    ln -sfn "$SCRIPT_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"

    if [ ! -f "$HOME/.claude/settings.json" ]; then
        ln -sfn "$SCRIPT_DIR/agents/claude_settings.json" "$HOME/.claude/settings.json"
    fi

    for skill_path in "$SUPERPOWERS_DIR"/skills/*; do
        if [ -d "$skill_path" ]; then
            skill_name=$(basename "$skill_path")
            ln -sfn "$skill_path" "$HOME/.claude/skills/$skill_name"
        fi
    done
    echo "Claude Code configuration complete."
fi
