# Setup fzf
# ---------
if [[ ! "$PATH" == *"$HOME/.fzf/bin"* ]] && [[ -d "$HOME/.fzf/bin" ]]; then
    PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

if ! command -v fzf &>/dev/null; then
    return
fi

if [[ ! -d "$HOME/.fzf" ]]; then
    return
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.fzf/shell/key-bindings.bash"

