# Progress Status

## Completed Features
- **Project Initialization**: Created Memory Bank structure.
- **Decoupling Sync**: Removed Google Drive dependency from `setup_links.sh`.
- **Package Simplification**: Cleaned up `Brewfile` and `Brewfile-casks-store`.
- **Location Awareness**: Refactored `setup_mac.sh`, `setup_links.sh`, and `setup_zsh.sh` to use dynamic paths.
- **Tmux Cleanup**: Removed `setup_tmux.sh` call from `setup_mac.sh`.
- **Configuration Sync**: Updated `rc/zshrc` to match the current machine's configuration.
- **Docker Removal**: Removed all Docker-related scripts, plugins, and configurations.
- **Email Verification**: Verified that `rc/gitconfig` uses `andersonduboc@gmail.com` and removed any legacy email addresses (none found).
- **Cleanup**: Removed references to deleted config folders (neofetch).
- **Bug Fix**: Fixed missing argument assignment in `setup_links.sh`.

## Pending Features
- **Secret Management**: Establish a new way to handle secrets (SSH keys, etc.) now that Google Drive sync is gone.
- **Testing**: Verify the "clean install" flow on a fresh machine (or VM).

## Known Issues
- `setup_zsh.sh` still relies on hardcoded `$HOME/.dotfiles` and attempts to clone the repo there if missing. This creates a potential "dual repo" confusion if the user runs `setup_mac.sh` from a different location.
