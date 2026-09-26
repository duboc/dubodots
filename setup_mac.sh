#!/bin/bash
set -e

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$HOME"

echo "Checking Developer Tools installation..."
echo "======================================================="

# Test for XCode Command Line Tools install
if ! xcode-select -p &>/dev/null; then
    echo "Xcode Command Line Tools not installed. Triggering installation..."
    xcode-select --install
else
    echo "Developer Tools detected."
fi
echo ""

# Test if homebrew is installed
echo "Checking Homebrew installation..."
if ! command -v brew &>/dev/null; then
    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "Homebrew not installed, installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ -x "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
else
    echo "Homebrew is installed ($(command -v brew)). Updating..."
    brew update
fi
echo ""

echo "Installing Brew packages..."
echo "==================================="
if [ -f "$SCRIPT_DIR/Brewfile" ]; then
    brew bundle install --file "$SCRIPT_DIR/Brewfile"
fi

# Install Go via Homebrew only if not already provided on the system
if ! command -v go &>/dev/null && [ ! -x "/usr/local/go/bin/go" ]; then
    echo "Go not detected on system, installing via Homebrew..."
    brew install go
else
    echo "Go is already installed ($(command -v go || echo /usr/local/go/bin/go))."
fi

if [ "${INSTALL_CASKS:-0}" = "1" ] && [ -f "$SCRIPT_DIR/Brewfile-casks-store" ]; then
    echo "Installing Casks..."
    brew bundle install --file "$SCRIPT_DIR/Brewfile-casks-store" || echo "Note: Skipping optional casks that require manual installation or are already installed."
fi
echo "Brew bundle finished."
echo ""

# Install additional fonts in user-space font directory (~/Library/Fonts)
echo "Installing fonts into user directory (~/Library/Fonts)..."
mkdir -p "$HOME/Library/Fonts"
if [ -d "$SCRIPT_DIR/fonts" ]; then
    cp "$SCRIPT_DIR/fonts/"* "$HOME/Library/Fonts/" 2>/dev/null || true
fi

# Install Go applications
if [ -f "$SCRIPT_DIR/go_apps.sh" ]; then
    bash "$SCRIPT_DIR/go_apps.sh"
fi

# Setup Git User Identity
if [ -f "$SCRIPT_DIR/setup_git_user.sh" ]; then
    bash "$SCRIPT_DIR/setup_git_user.sh"
fi

# Setup dotfiles links
if [ -f "$SCRIPT_DIR/setup_links.sh" ]; then
    bash "$SCRIPT_DIR/setup_links.sh"
fi

# Setup Zsh
if [ -f "$SCRIPT_DIR/setup_zsh.sh" ]; then
    bash "$SCRIPT_DIR/setup_zsh.sh"
fi

# Setup macOS preferences
if [ -f "$SCRIPT_DIR/osx_prefs.sh" ]; then
    bash "$SCRIPT_DIR/osx_prefs.sh"
fi

# Add TouchID authentication to Sudo using pam_tid.so (only when /etc/pam.d/sudo includes sudo_local)
if [ -f /etc/pam.d/sudo_local.template ] && [ ! -f /etc/pam.d/sudo_local ] && grep -q "sudo_local" /etc/pam.d/sudo 2>/dev/null; then
    echo "Configuring TouchID for sudo via /etc/pam.d/sudo_local..."
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    sudo sed -i '' 's/#auth       sufficient     pam_tid.so/auth       sufficient     pam_tid.so/' /etc/pam.d/sudo_local
fi

echo ""
echo "Setup finished!"
echo "NEXT STEPS:"
echo "1. If your login shell is not yet Zsh, run 'chsh -s /bin/zsh' in your terminal."
echo "2. Restart your terminal to apply all Zsh changes."



