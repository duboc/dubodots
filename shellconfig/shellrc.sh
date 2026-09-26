###
# Generic shellrc to be used by both zshrc and bashrc
###

# NOTE: problems might occur if /bin/sh is symlinked to /bin/bash
if [ -n "${BASH}" ]; then
    shell="bash"
elif [ -n "${ZSH_NAME}" ]; then
    shell="zsh"
fi

# Load exports
source ~/.dotfiles/shellconfig/exports.sh

# Functions
source ~/.dotfiles/shellconfig/funcs.sh

# Load generic aliases
source ~/.dotfiles/shellconfig/aliases.sh

# Load Mac aliases
if [ `uname -s` = 'Darwin' ]; then
    source ~/.dotfiles/shellconfig/aliases_mac.sh
fi

#####
# Now load plugins and utilities
#####

# Enable autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && source /usr/local/etc/profile.d/autojump.sh # Mac
[ -f /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh # Linux

# Wasmer
export WASMER_DIR="$HOME/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"  # This loads wasmer

# Use gitstatusd built locally if exists
if command -v "$HOME/.dotfiles/bin/gitstatusd-linux-$(uname -m)" &> /dev/null; then
    GITSTATUS_DAEMON="$HOME/.dotfiles/bin/gitstatusd-linux-$(uname -m)"
fi

# Load fzf plugin. Installed thru setup_zsh.sh
[ -f ~/.fzf.${shell} ] && source ~/.fzf.${shell}

# Kubernetes
if command -v kubectl &>/dev/null; then
  source ~/.dotfiles/shellconfig/kubernetes.sh
fi

# Agentic & Cloud AI FDE helpers
if [ -f ~/.dotfiles/shellconfig/agents.sh ]; then
  source ~/.dotfiles/shellconfig/agents.sh
fi

# Load stern log tool completion
if command -v stern &>/dev/null && [ -n "${shell}" ]; then
  source <(stern --completion="${shell}")
fi

# Load iTerm2 integration only inside iTerm2 and when bash extdebug is not enabled
if [ "$TERM_PROGRAM" = "iTerm.app" ] && [ -f "${HOME}/.dotfiles/shellconfig/iterm2_shell_integration.${shell}" ]; then
  if [ "${shell}" != "bash" ] || ! shopt -q extdebug 2>/dev/null; then
    source "${HOME}/.dotfiles/shellconfig/iterm2_shell_integration.${shell}"
  fi
fi

#####
# These are at the end to print on user login
#####


if command -v tmux &>/dev/null && tmux list-sessions > /dev/null 2>&1; then
    echo ""
    echo "There are TMux sessions running:"
    echo ""
    tmux list-sessions
    echo ""
fi

