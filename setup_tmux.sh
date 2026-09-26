#!/bin/bash

echo "Starting Tmux setup"
echo ""
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES="${DOTFILES:-$SCRIPT_DIR}"
pushd "$HOME" >/dev/null

tmuxcommand=tmux
if ! command -v "$tmuxcommand" &>/dev/null; then
    if [ "$(uname)" == "Darwin" ]; then
        echo "Note: $tmuxcommand is not installed. Please install it via your preferred package manager."
    else
        # Install tmux on Linux
        if grep -qi "debian\|ubuntu" /etc/os-release 2>/dev/null; then
            sudo apt update
            sudo apt install -y "$tmuxcommand"
        elif grep -qi "fedora" /etc/os-release 2>/dev/null; then
            sudo dnf install -y "$tmuxcommand"
        fi
    fi
fi

if [ -f "$DOTFILES/setup_links.sh" ]; then
    bash "$DOTFILES/setup_links.sh"
fi

echo "Installing/updating Tmux Plugin Manager (tpm)..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "tpm is already installed, updating..."
    (cd "$HOME/.tmux/plugins/tpm" && git pull)
fi
popd >/dev/null


