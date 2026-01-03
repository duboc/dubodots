#!/bin/bash

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$HOME"

echo "Don't forget to install XCode or Developer tools"
echo "======================================================="
echo ""
echo "Testing if you have XCode or Developer tools already installed"
echo ""

# Keep-alive: update existing `sudo` time stamp until finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
echo ""
# Test for XCode install
if [[ ! `which gcc` ]]; then
    echo "Xcode/Dev Tools not installed. Installing..."
    xcode-select --install
else
    echo "Dev Tools detected, installation will proceed in 2 seconds"
fi
echo ""
sleep 2

# Test if homebrew is installed
echo "Testing if you have Homebrew already installed"
echo ""
if [[ ! `which brew` ]]; then
    echo "Homebrew not installed, installing..."
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is installed, will update"
    echo ""
    brew update
fi
sleep 3

echo "Install brews"
echo "==================================="
echo ""
# Command line apps
brew bundle install --file "$SCRIPT_DIR/Brewfile"
# Mac apps
brew bundle install --file "$SCRIPT_DIR/Brewfile-casks-store"
echo ""
echo "done ..."
echo ""
sleep 1

# Install additional fonts
sudo cp "$SCRIPT_DIR/fonts/"* /Library/Fonts

# Install Go applications
bash -c "$SCRIPT_DIR/go_apps.sh"

# Setup dotfiles
bash -c "$SCRIPT_DIR/setup_links.sh"

# Setup Zsh
bash -c "$SCRIPT_DIR/setup_zsh.sh"

# Setup OsX defaults
bash -c "$SCRIPT_DIR/osx_prefs.sh"

# Add TouchID authentication to Sudo
if [[ ! `grep "pam_tid.so" /etc/pam.d/sudo` ]]; then
    echo -e "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" |sudo tee /etc/pam.d/sudo;
fi

# Add user to passwordless sudo
#sudo sed -i "%admin    ALL = (ALL) NOPASSWD:ALL"

echo "Setup finished!"
echo ""
echo "NEXT STEPS:"
echo "1. Run 'gcloud auth login' to set up Google Cloud SDK."
echo "2. Run 'gcloud auth application-default login' if you need ADC."
echo "3. Restart your terminal to apply Zsh changes."
