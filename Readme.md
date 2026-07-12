# Console Dotfiles (`dubodots`)

A modular, cross-platform collection of dotfiles, shell scripts, and system configurations designed for macOS and Linux. Built with shell scripting best practices, user-space isolation, Apple Silicon (ARM64) and Intel compatibility, and non-destructive installation patterns.

## Features & Design Principles

* **Cross-Platform & Architecture Aware**: Automatically resolves Homebrew paths (`/opt/homebrew` on Apple Silicon vs `/usr/local` on Intel macOS / Linux).
* **Least-Privilege & User-Space Priority**: Installs custom fonts into user directories (`~/Library/Fonts`) without requiring root access or `sudo`.
* **Idempotent & Non-Destructive**: Safe to re-run anytime. Preserves existing `.config/` directories when linking custom application configs.
* **Modern Tooling & Up-to-Date Sources**: Uses `go install` for Go binaries, maintained Zsh plugins (e.g., `zdharma-continuum`), and current Oh My Zsh repositories.
* **Touch ID for Sudo (macOS)**: Integrates Touch ID authentication using `/etc/pam.d/sudo_local`, preserving system compatibility across OS upgrades.

## Installation

### macOS Setup

Run the standard macOS setup script:

```sh
# Clone repository to user home directory
git clone https://github.com/duboc/dubodots $HOME/.dotfiles
cd $HOME/.dotfiles

# Execute macOS setup script
./setup_mac.sh
```

Restart your terminal session after setup completes to reload Zsh configurations and environment settings.

### Linux Setup

Run the Linux setup script:

```sh
# Clone repository to user home directory
git clone https://github.com/duboc/dubodots $HOME/.dotfiles
cd $HOME/.dotfiles

# Execute Linux setup script
./setup_linux.sh
```

Restart your terminal session after setup completes.

### Proxy & Custom Network Environments

If operating behind a custom HTTP/HTTPS proxy or restricted network environment, export your proxy variables before running the setup scripts:

```sh
export http_proxy="http://proxy.example.com:8080"
export https_proxy="http://proxy.example.com:8080"
```

Ensure `npm`, `git`, and `curl` are configured with any required custom CA certificates.

## Shell Configuration

### Zsh & Oh My Zsh

* **Theme**: Powerlevel10k prompt.
* **Plugins**: Autosuggestions, fast-syntax-highlighting, history-substring-search, you-should-use, forgit, and completions.
* **Shell Switching**: `setup_zsh.sh` inspects the active user shell (`dscl` on macOS) and safely configures Zsh as the user default.

### Tmux & Visual Themes

* Customized tmux layout using `blue.tmuxtheme`.
* Configured via `setup_tmux.sh`.

## File & Directory Structure

```
dubodots/
├── bin/                 # Helper scripts and platform-specific binaries added to $PATH
├── completion/          # Shell completion scripts for Zsh & Bash (e.g., kubectx, kubens)
├── fonts/               # Monospaced fonts (patched with Nerd Fonts icons)
├── rc/                  # Application runtime configuration files symlinked to ~/.rc
│   └── config/          # Sub-configurations symlinked into ~/.config/ (git, htop, iterm2)
├── shellconfig/         # Shared shell configuration scripts for Zsh and Bash
│   ├── aliases.sh       # Cross-platform command aliases
│   ├── aliases_mac.sh   # macOS specific application aliases
│   ├── exports.sh       # PATH, environment variables, and tool bindings
│   ├── funcs.sh         # Shell utility functions
│   ├── kubernetes.sh    # Kubernetes / kubectl helpers
│   └── shellrc.sh       # Main entry point loaded by .zshrc and .bashrc
├── Brewfile             # Core Homebrew formulae for macOS
├── Brewfile-casks-store # Applications installed via Homebrew Casks
├── go_apps.sh           # Go developer binaries installer (go install)
├── osx_prefs.sh         # macOS user defaults and productivity tweaks
├── setup_links.sh       # Symlink generator for dotfiles and config directories
├── setup_mac.sh         # Master orchestration script for macOS
├── setup_linux.sh       # Master orchestration script for Linux
├── setup_tmux.sh        # Tmux environment setup
└── setup_zsh.sh         # Zsh framework, theme, and plugin manager
```
