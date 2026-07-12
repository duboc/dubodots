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

if [ -f "$SCRIPT_DIR/Brewfile-casks-store" ]; then
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

# Add TouchID authentication to Sudo using pam_tid.so (prefers macOS sudo_local if available)
echo "Configuring TouchID for sudo (if supported)..."
if [ -f /etc/pam.d/sudo_local.template ] && [ ! -f /etc/pam.d/sudo_local ]; then
    echo "Setting up /etc/pam.d/sudo_local for TouchID..."
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    sudo sed -i '' 's/#auth       sufficient     pam_tid.so/auth       sufficient     pam_tid.so/' /etc/pam.d/sudo_local
elif [ -f /etc/pam.d/sudo ] && ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
    echo "Adding pam_tid.so to /etc/pam.d/sudo..."
    echo -e "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" | sudo tee /etc/pam.d/sudo >/dev/null
fi

echo ""
echo "Setup finished!"
echo "NEXT STEPS:"
echo "1. Run 'gcloud auth login' to set up Google Cloud SDK if needed."
echo "2. Run 'gcloud auth application-default login' if you need ADC."
echo "3. Restart your terminal to apply all Zsh changes."

