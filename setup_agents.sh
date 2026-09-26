#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPERPOWERS_DIR="$HOME/.local/share/superpowers"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"

echo "Configuring AI Coding Agents & obra/superpowers..."

# 1. Clone or update obra/superpowers
mkdir -p "$HOME/.local/share"
if [ ! -d "$SUPERPOWERS_DIR/.git" ]; then
    echo "Cloning obra/superpowers into $SUPERPOWERS_DIR..."
    git clone --depth 1 "$SUPERPOWERS_REPO" "$SUPERPOWERS_DIR"
else
    echo "Updating obra/superpowers..."
    git -C "$SUPERPOWERS_DIR" pull --ff-only 2>/dev/null || true
fi

# 2. Universal Cross-Agent Skills Directory (~/.agents/skills & ~/.gemini/skills)
mkdir -p "$HOME/.agents/skills" "$HOME/.gemini/skills"
for skill_path in "$SUPERPOWERS_DIR"/skills/*; do
    if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        ln -sfn "$skill_path" "$HOME/.agents/skills/$skill_name"
        ln -sfn "$skill_path" "$HOME/.gemini/skills/$skill_name"
    fi
done

# 3. Configure Antigravity & Gemini Global Config (~/.gemini/config)
mkdir -p "$HOME/.gemini/config/plugins" "$HOME/.gemini/config/rules"

# Install superpowers into ~/.gemini/config/plugins/superpowers
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

# Register global skills.json for ~/.gemini/config discovery
cat <<EOF > "$HOME/.gemini/config/skills.json"
{
  "entries": [
    {
      "path": "~/.local/share/superpowers/skills"
    }
  ]
}
EOF

# Create always_on global rules for Antigravity so using-superpowers and engineering standards auto-load
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

# Configure ~/.gemini/GEMINI.md for Gemini CLI
cat <<'EOF' > "$HOME/.gemini/GEMINI.md"
@~/.local/share/superpowers/skills/using-superpowers/SKILL.md
@~/.local/share/superpowers/skills/using-superpowers/references/gemini-tools.md
@~/.dotfiles/agents/AGENTS.md
EOF

# 4. Configure Claude Code (~/.claude)
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

echo "AI Coding Agents (Antigravity, Gemini CLI, Claude Code) & obra/superpowers configured."
