#!/usr/bin/env bash
set -e

echo "Starting Herdr setup"
echo ""
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES="${DOTFILES:-$SCRIPT_DIR}"
pushd "$HOME" >/dev/null

# Ensure ~/.local/bin is in PATH for Linux/direct installs
export PATH="$HOME/.local/bin:$PATH"

if ! command -v herdr &>/dev/null; then
    if [ "$(uname -s)" = "Darwin" ]; then
        if command -v brew &>/dev/null; then
            echo "Installing herdr via Homebrew..."
            brew install herdr
        else
            echo "Installing herdr via official installer..."
            curl -fsSL https://herdr.dev/install.sh | sh
        fi
    else
        echo "Installing herdr via official installer..."
        curl -fsSL https://herdr.dev/install.sh | sh
    fi
else
    echo "Herdr is already installed ($(command -v herdr))."
fi

if [ -f "$DOTFILES/setup_links.sh" ]; then
    bash "$DOTFILES/setup_links.sh"
fi

# Install Herdr session-restore integrations for configured agent harnesses
if command -v herdr &>/dev/null; then
    if [ -d "$HOME/.claude" ]; then
        # Ensure ~/.claude/settings.json is a regular writable file before Herdr adds hooks
        if [ -L "$HOME/.claude/settings.json" ]; then
            target_settings="$(readlink "$HOME/.claude/settings.json")"
            rm -f "$HOME/.claude/settings.json"
            if [ -f "$target_settings" ]; then
                cp "$target_settings" "$HOME/.claude/settings.json"
            elif [ -f "$DOTFILES/agents/claude_settings.json" ]; then
                cp "$DOTFILES/agents/claude_settings.json" "$HOME/.claude/settings.json"
            fi
        fi
        echo "Installing Herdr integration for Claude Code..."
        herdr integration install claude 2>/dev/null || true
    fi

    if [ -d "$HOME/.gemini/config" ]; then
        echo "Installing Herdr integration for Antigravity CLI..."
        herdr integration install antigravity-cli 2>/dev/null || true
    fi

    if [ -d "$HOME/.codex" ]; then
        echo "Installing Herdr integration for Codex..."
        herdr integration install codex 2>/dev/null || true
    fi
fi

popd >/dev/null
echo "Herdr setup complete."
