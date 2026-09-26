#!/bin/bash

# Check pre-reqs
if ! command -v git &>/dev/null || ! command -v curl &>/dev/null; then
    echo "Curl or git not installed..."
    exit 1
fi

echo "Starting Zsh setup..."
echo ""

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check Homebrew environment
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Ensure Zsh is installed
if ! command -v zsh &>/dev/null; then
    echo "Zsh not found, installing..."
    if [ "$(uname)" == "Darwin" ]; then
        brew install zsh
    else
        if grep -qi "debian\|ubuntu" /etc/os-release 2>/dev/null; then
            sudo apt update && sudo apt install -y zsh
        elif grep -qi "fedora" /etc/os-release 2>/dev/null; then
            sudo dnf install -y zsh
        fi
    fi
fi

# Set default shell if needed (prefer system /bin/zsh on macOS)
if [ "$(uname)" == "Darwin" ] && [ -x "/bin/zsh" ]; then
    ZSH_PATH="/bin/zsh"
else
    ZSH_PATH="$(which zsh)"
fi
CURRENT_SHELL="$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}')"
if [ -n "$CURRENT_SHELL" ] && [ "$CURRENT_SHELL" != "$ZSH_PATH" ] && [ "$CURRENT_SHELL" != "/bin/zsh" ]; then
    echo "Current shell is $CURRENT_SHELL. Attempting to change default shell to $ZSH_PATH..."
    if [ -t 0 ]; then
        chsh -s "$ZSH_PATH" || echo "Note: To change default shell to zsh, run: chsh -s $ZSH_PATH"
    else
        echo "Note: Non-interactive shell detected. To change default shell to zsh, run: chsh -s $ZSH_PATH"
    fi
fi


echo ""
echo "Installing/Updating Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
    echo "Oh My Zsh is already installed, updating..."
    (cd "$HOME/.oh-my-zsh" && git pull --rebase --autostash)
fi

echo ""
echo "Checking fzf configuration..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --bin || true
else
    echo "Updating fzf..."
    (cd "$HOME/.fzf" && git pull --depth 1)
    "$HOME/.fzf/install" --bin || true
fi

echo ""
echo "Adding custom completion scripts..."
mkdir -p "$HOME/.oh-my-zsh/custom/completions"
if [ -d "$SCRIPT_DIR/completion" ]; then
    for FILE in "$SCRIPT_DIR/completion/"*; do
        [ -e "$FILE" ] || continue
        ln -sfn "$FILE" "$HOME/.oh-my-zsh/custom/completions/_$(basename "$FILE")"
    done
fi

# Link .rc files
if [ -f "$SCRIPT_DIR/setup_links.sh" ]; then
    bash "$SCRIPT_DIR/setup_links.sh"
fi

# Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

themes=(
    "https://github.com/romkatv/powerlevel10k"
)

for t in "${themes[@]}"; do
    theme_name="$(basename "$t")"
    echo "Checking theme $theme_name..."
    if [ ! -d "$ZSH_CUSTOM/themes/$theme_name" ]; then
        echo "Installing $theme_name..."
        git clone --depth 1 "$t" "$ZSH_CUSTOM/themes/$theme_name"
    else
        echo "Updating $theme_name..."
        (cd "$ZSH_CUSTOM/themes/$theme_name" && git pull)
    fi
    if [ -x "$ZSH_CUSTOM/themes/$theme_name/gitstatus/install" ]; then
        echo "Ensuring gitstatusd binary is installed for $theme_name..."
        "$ZSH_CUSTOM/themes/$theme_name/gitstatus/install" || true
    fi
done

# Active plugins array (explicitly updated via setup_zsh.sh, no background auto-pulling)
plugins=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zdharma-continuum/fast-syntax-highlighting"
    "https://github.com/zsh-users/zsh-completions"
    "https://github.com/zsh-users/zsh-history-substring-search"
    "https://github.com/MichaelAquilina/zsh-you-should-use"
    "https://github.com/wfxr/forgit"
)

plugin_names=()
mkdir -p "$ZSH_CUSTOM/plugins"
for p in "${plugins[@]}"; do
    plugin_name="$(basename "$p")"
    plugin_names+=("$plugin_name")
    echo "Installing/updating plugin $plugin_name..."
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
        git clone --depth 1 "$p" "$ZSH_CUSTOM/plugins/$plugin_name"
    else
        (cd "$ZSH_CUSTOM/plugins/$plugin_name" && git pull --rebase --autostash)
    fi
done

# Helper function
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

echo ""
echo "Cleaning unused plugins..."
if [ -d "$ZSH_CUSTOM/plugins" ]; then
    for d in "$ZSH_CUSTOM/plugins/"*; do
        [ -d "$d" ] || continue
        dirname="$(basename "$d")"
        if containsElement "$dirname" "${plugin_names[@]}"; then
            echo "Keeping plugin: $dirname"
        else
            echo "Removing obsolete plugin: $dirname"
            rm -rf "$d"
        fi
    done
fi

echo ""
echo "Checking kubectx / kubens..."
mkdir -p "$SCRIPT_DIR/bin" "$SCRIPT_DIR/completion"
for X in kubectx kubens; do
    if [ ! -f "$SCRIPT_DIR/bin/$X" ]; then
        curl -sL -o "$SCRIPT_DIR/bin/$X" "https://raw.githubusercontent.com/ahmetb/kubectx/master/$X"
    fi
    chmod +x "$SCRIPT_DIR/bin/$X"
    if [ ! -f "$SCRIPT_DIR/completion/$X.bash" ]; then
        curl -sL -o "$SCRIPT_DIR/completion/$X.bash" "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.bash"
    fi
    if [ ! -f "$SCRIPT_DIR/completion/$X.zsh" ]; then
        curl -sL -o "$SCRIPT_DIR/completion/$X.zsh" "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.zsh"
    fi
    chmod +x "$SCRIPT_DIR/completion/$X.bash" "$SCRIPT_DIR/completion/$X.zsh"
done

echo ""
echo "Cleaning completion cache..."
rm -f "$HOME/.zcompdump"*

echo "Zsh setup finished successfully."
