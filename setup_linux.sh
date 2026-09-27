#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$HOME"

BASEPACKAGES="sudo openssh-client openssh-server curl wget git file dbus bc bash-completion hdparm sysstat less vim iptables ipset pciutils iperf3 net-tools jq haveged htop zsh tmux autojump lshw telnet iotop tree ripgrep fd-find"
DEBIANPACKAGES="locales ack nfs-common apt-utils build-essential"
FEDORAPACKAGES="ack nfs-utils @development-tools"
ALPINEPACKAGES="ack nfs-utils build-base"

# Install Linux packages
if grep -qi "ID=debian\|ID=ubuntu" /etc/os-release 2>/dev/null; then
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y $BASEPACKAGES $DEBIANPACKAGES
elif grep -qi "ID=fedora" /etc/os-release 2>/dev/null; then
    sudo dnf upgrade -y
    sudo dnf install -y $BASEPACKAGES $FEDORAPACKAGES
elif grep -qi "ID=alpine" /etc/os-release 2>/dev/null; then
    sudo apk update
    sudo apk add $BASEPACKAGES $ALPINEPACKAGES
fi

# Install agentic workflow CLIs (just, gh, uv); best effort per package, never fatal
if grep -qi "ID=debian\|ID=ubuntu" /etc/os-release 2>/dev/null; then
    for pkg in just gh; do
        sudo apt install -y "$pkg" || echo "Note: $pkg not available from apt on this release; install it manually."
    done
elif grep -qi "ID=fedora" /etc/os-release 2>/dev/null; then
    for pkg in just gh uv; do
        sudo dnf install -y "$pkg" || echo "Note: $pkg not available from dnf; install it manually."
    done
elif grep -qi "ID=alpine" /etc/os-release 2>/dev/null; then
    for pkg in just github-cli uv; do
        sudo apk add "$pkg" || echo "Note: $pkg not available from apk; install it manually."
    done
fi
if ! command -v uv &>/dev/null && [ ! -x "$HOME/.local/bin/uv" ]; then
    echo "Installing uv (Astral) into ~/.local/bin..."
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh || echo "Note: uv install failed; see https://docs.astral.sh/uv/"
fi

# Install Golang if not already present
if ! command -v go &>/dev/null && [ ! -x "/usr/local/go/bin/go" ]; then
    GOVERSION="$(curl -fsSL 'https://go.dev/VERSION?m=text' 2>/dev/null | head -n 1 || echo 'go1.24.1')"
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64*)  P_ARCH=amd64 ;;
        aarch64*) P_ARCH=arm64 ;;
        arm*hf)   P_ARCH=arm6l ;;
        *)
            echo "Install golang error: unsupported arch '${ARCH}'" >&2
            P_ARCH=""
            ;;
    esac
    if [ -n "$P_ARCH" ]; then
        echo "Installing ${GOVERSION} for linux-${P_ARCH}..."
        curl -fsSL "https://dl.google.com/go/${GOVERSION}.linux-${P_ARCH}.tar.gz" | sudo tar -xzf - -C /usr/local
        export PATH="/usr/local/go/bin:$PATH"
        echo "Installed ${GOVERSION} for ${P_ARCH}"
        echo ""
    fi
else
    echo "Go is already installed ($(command -v go || echo /usr/local/go/bin/go))."
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

# Setup Tmux
if [ -f "$SCRIPT_DIR/setup_tmux.sh" ]; then
    bash "$SCRIPT_DIR/setup_tmux.sh"
fi

# Optional: Setup AI Coding Agents & obra/superpowers only when explicitly requested
if [ "${INSTALL_AGENTS:-0}" = "1" ] || [ "${INSTALL_CLAUDE:-0}" = "1" ] || [ "${INSTALL_ANTIGRAVITY:-0}" = "1" ]; then
    if [ -f "$SCRIPT_DIR/setup_agents.sh" ]; then
        bash "$SCRIPT_DIR/setup_agents.sh"
    fi
fi

echo "Setup finished!"

