# Larger bash history
export HISTSIZE=50000000;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
export HISTIGNORE=" *:ls:cd:cd -:pwd:exit:date:* --help:* -h:history*";
export HISTTIMEFORMAT="%d/%m/%y %T "

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";

# Do not clear screen after exiting LESS
unset LESS

# Make vim default editor
export EDITOR="vim"

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Keybindings for forgit / fzf
export FORGIT_FZF_DEFAULT_OPTS="
$FORGIT_FZF_DEFAULT_OPTS
--bind='alt-up:preview-up'
--bind='alt-down:preview-down'
--no-mouse
"

# Homebrew setup (Apple Silicon / Intel dynamically)
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Additional PATH exports
export PATH="$HOME/.dotfiles/bin:$PATH"
[ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ] && export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
[ -d "/usr/local/opt/coreutils/libexec/gnubin" ] && export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

## Golang path
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Set JAVA home dir
if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
fi

# Google Cloud / Kubernetes
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
