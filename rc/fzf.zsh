# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/duboc/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/duboc/.fzf/bin"
fi

source <(fzf --zsh)
