# Functions when required functionality won't work with an alias

# Generate a scp command to copy files between hosts
scppath () {
    echo $USER@`hostname -I | awk '{print $1}'`:`readlink -f $1`;
}

# Call journalctl for process or all if no arguments
jo () {
    if [[ "$1" != "" ]]; then
        sudo journalctl -xef -u $1;
    else
        sudo journalctl -xef;
    fi
}


# Generate a patch email from git commits
function gpatch () {
    if [[ $1 != "" ]]; then
        git format-patch HEAD~$1
    else
        git format-patch HEAD~
    fi
}

# Send patch file with git
function gsendpatch () {
  echo 'If replying to an existing message, add "--in-reply-to messageIDfromMessage@somehostname.com" param'
  patch=$1
  shift
  git send-email \
    --cc-cmd="./scripts/get_maintainer.pl --norolestats $patch" \
    $@ $patch
}

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick find
qfind() {
  find . -name "*$1*"
}

# Extract various archive formats
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# NVM - Lazy load for faster shell startup
# Requires NVM installed at ~/.nvm
nvm_lazy_load() {
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
      nvm() {
        unset -f nvm node npm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm "$@"
      }
      node() {
        unset -f nvm node npm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        node "$@"
      }
      npm() {
        unset -f nvm node npm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        npm "$@"
      }
    fi
}
# Initialize lazy load
nvm_lazy_load
