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

# Set default shell if needed (macOS default shell is already /bin/zsh)
ZSH_PATH="$(which zsh)"
CURRENT_SHELL="$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}')"
if [ "$CURRENT_SHELL" != "$ZSH_PATH" ] && [ "$CURRENT_SHELL" != "/bin/zsh" ]; then
    echo "Current shell is $CURRENT_SHELL. Attempting to change default shell to $ZSH_PATH..."
    if [ -t 0 ]; then
        chsh -s "$ZSH_PATH" || sudo chsh -s "$ZSH_PATH" "$USER" || true
    else
        sudo chsh -s "$ZSH_PATH" "$USER" 2>/dev/null || echo "Note: To change default shell to zsh, run: sudo chsh -s $ZSH_PATH $USER"
    fi
fi


echo ""
echo "Installing/Updating Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed, updating..."
    (cd "$HOME/.oh-my-zsh" && git pull --rebase --autostash)
fi

echo ""
echo "Checking fzf configuration..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish || true
else
    echo "Updating fzf..."
    (cd "$HOME/.fzf" && git pull --depth 1)
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
        git clone "$t" "$ZSH_CUSTOM/themes/$theme_name"
    else
        echo "Updating $theme_name..."
        (cd "$ZSH_CUSTOM/themes/$theme_name" && git pull)
    fi
done

# Active plugins array (fixed zdharma-continuum URL)
plugins=(
    "https://github.com/TamCore/autoupdate-oh-my-zsh-plugins"
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
        git clone "$p" "$ZSH_CUSTOM/plugins/$plugin_name"
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
echo "Updating kubectx / kubens..."
mkdir -p "$SCRIPT_DIR/bin" "$SCRIPT_DIR/completion"
for X in kubectx kubens; do
    curl -sL -o "$SCRIPT_DIR/bin/$X" "https://raw.githubusercontent.com/ahmetb/kubectx/master/$X"
    chmod +x "$SCRIPT_DIR/bin/$X"
    curl -sL -o "$SCRIPT_DIR/completion/$X.bash" "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.bash"
    curl -sL -o "$SCRIPT_DIR/completion/$X.zsh" "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.zsh"
    chmod +x "$SCRIPT_DIR/completion/$X.bash" "$SCRIPT_DIR/completion/$X.zsh"
done

echo ""
echo "Cleaning completion cache..."
rm -f "$HOME/.zcompdump"*

echo "Zsh setup finished successfully."
