#!/bin/bash
# MacOS System Preferences & Productivity Configuration

echo "Applying MacOS user preferences..."

# Keyboard: Enable full keyboard navigation (Tab in modals)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Keyboard: Disable press-and-hold for keys in favor of key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Dock: Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Dock: Make icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Dock: Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Dock: Enable spring loading for items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Screenshots: Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Finder: Show status bar and path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Finder: Search the current folder by default when searching
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Finder: Allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Save Panels: Expand save panel and print panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g PMPrintingExpandedStateForPrint -bool true

# Network: Avoid creating .DS_Store files on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Trackpad: Enable tap to click for current user
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Show user ~/Library folder
chflags nohidden ~/Library 2>/dev/null || true

# Terminal: Set default font for iTerm2 if present
if defaults read com.googlecode.iterm2 >/dev/null 2>&1; then
    echo "Configuring iTerm2 default font to MesloLGS NF..."
    defaults write com.googlecode.iterm2 "Normal Font" -string "MesloLGS-NF-Regular 13" 2>/dev/null || true
    if [ -f "$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]; then
        /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:0:Normal Font' 'MesloLGS-NF-Regular 13'" "$HOME/Library/Preferences/com.googlecode.iterm2.plist" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:0:Non Ascii Font' 'MesloLGS-NF-Regular 13'" "$HOME/Library/Preferences/com.googlecode.iterm2.plist" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:0:Non Ascii Font' string 'MesloLGS-NF-Regular 13'" "$HOME/Library/Preferences/com.googlecode.iterm2.plist" 2>/dev/null || true
    fi
fi

# Terminal: Set default font for Ghostty if present and not yet configured
GHOSTTY_CONFIG="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
if [ -d "/Applications/Ghostty.app" ] && [ -f "$GHOSTTY_CONFIG" ]; then
    if ! grep -q "font-family" "$GHOSTTY_CONFIG" 2>/dev/null; then
        echo "Configuring Ghostty default font to MesloLGS NF..."
        echo 'font-family = "MesloLGS NF"' >> "$GHOSTTY_CONFIG"
    fi
fi

echo "Restarting UI services to apply changes..."
for app in Finder Dock cfprefsd; do
    killall "$app" >/dev/null 2>&1 || true
done

echo "MacOS preferences applied successfully."

