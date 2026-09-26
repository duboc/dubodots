#------------------------------------------////
# Only for Mac OSX
#------------------------------------------////

alias brewupd='brew update && brew upgrade && brew cleanup'
alias brewdeps='brew list -1 | while read cask; do echo -ne "\x1B[1;34m $cask \x1B[0m"; brew uses $cask --installed | awk '"'"'{printf(" %s ", $0)}'"'"'; echo ""; done'

# Use GNU utils as default only if installed
command -v gindent &>/dev/null && alias indent='gindent'
command -v gsed &>/dev/null && alias sed='gsed'
command -v gtar &>/dev/null && alias tar='gtar'
command -v gmake &>/dev/null && alias make='gmake'
command -v ggrep &>/dev/null && alias grep='ggrep'
command -v gwhich &>/dev/null && alias which='gwhich'

# Quicklook file. Depends on osx plugin from zsh oh-my-zsh
alias ql='quick-look'

command -v bat &>/dev/null && alias cat='bat --italic-text=always -p --pager "less -rX"'


# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Decode base64 string from the clipboard
alias clipdecode="pbpaste|base64 --decode"

# Flush Directory Service cache
alias flushdns="dscacheutil -flushcache && killall -HUP mDNSResponder"
