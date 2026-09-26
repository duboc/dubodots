# Setup fzf
# ---------
if [[ ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
elif [ -f "$HOME/.fzf/shell/key-bindings.zsh" ]; then
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null
  source "$HOME/.fzf/shell/key-bindings.zsh"
fi

