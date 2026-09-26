# Shell utility functions for terminal & cloud workflows

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Jump to the root of the current Git repository
cdr() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [ -n "$root" ]; then
    cd "$root"
  else
    echo "Not inside a Git repository." >&2
    return 1
  fi
}

# Quick file search (prefers fd if installed, falls back to find)
qfind() {
  if command -v fd &>/dev/null; then
    fd "$1"
  else
    find . -iname "*$1*"
  fi
}

# Show which process is listening on a given TCP port (or list all listening TCP ports)
whoport() {
  if [ -n "$1" ]; then
    lsof -iTCP:"$1" -sTCP:LISTEN -P -n
  else
    lsof -iTCP -sTCP:LISTEN -P -n
  fi
}

# Inspect remote TLS certificate (subject, issuer, SANs, and expiration dates)
certcheck() {
  local target="${1:?Usage: certcheck <hostname[:port]>}"
  local host="${target%:*}"
  local port="${target##*:}"
  if [ "$host" = "$port" ]; then
    port=443
  fi
  echo | openssl s_client -servername "$host" -connect "${host}:${port}" 2>/dev/null | \
    openssl x509 -noout -subject -issuer -dates -ext subjectAltName
}

# Decode a JWT token (header and payload) locally using base64 and jq
jwtdecode() {
  local token="${1:?Usage: jwtdecode <jwt-token>}"
  python3 -c '
import sys, json, base64
parts = sys.argv[1].split(".")
for idx, label in [(0, "Header"), (1, "Payload")]:
    if idx < len(parts):
        padded = parts[idx] + "=" * (-len(parts[idx]) % 4)
        data = json.loads(base64.urlsafe_b64decode(padded))
        print(f"=== {label} ===")
        print(json.dumps(data, indent=2))
' "$token"
}

# Convert YAML to JSON or JSON to YAML (requires yq)
yaml2json() {
  yq -o=json '.' "${1:--}"
}

json2yaml() {
  yq -P '.' "${1:--}"
}

# Interactive Git branch checkout using fzf
fbr() {
  if ! command -v fzf &>/dev/null; then
    echo "fzf is required for fbr" >&2
    return 1
  fi
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/.* //' | sed 's#remotes/[^/]*/##' | sort -u | fzf --height 40% --reverse --prompt="Checkout branch > ")
  if [ -n "$branch" ]; then
    git checkout "$branch"
  fi
}

# Interactive process kill using fzf
fkill() {
  if ! command -v fzf &>/dev/null; then
    echo "fzf is required for fkill" >&2
    return 1
  fi
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --height 40% --reverse --prompt="Kill process > " | awk '{print $2}')
  if [ -n "$pid" ]; then
    echo "$pid" | xargs kill -"${1:-9}"
  fi
}

# Generate an scp path string for a local file (cross-platform macOS & Linux)
scppath() {
  local ip fullpath
  if [ "$(uname -s)" = "Darwin" ]; then
    ip="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || hostname)"
  else
    ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  fi
  if command -v realpath &>/dev/null; then
    fullpath="$(realpath "$1")"
  else
    fullpath="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  fi
  echo "${USER}@${ip}:${fullpath}"
}

# Call journalctl for a systemd unit or all logs (Linux)
jo() {
  if [ -n "$1" ]; then
    sudo journalctl -xef -u "$1"
  else
    sudo journalctl -xef
  fi
}

# Generate a patch email from git commits
gpatch() {
  if [ -n "$1" ]; then
    git format-patch "HEAD~$1"
  else
    git format-patch HEAD~
  fi
}

# Send patch file with git
gsendpatch() {
  echo 'If replying to an existing message, add "--in-reply-to messageIDfromMessage@somehostname.com" param'
  local patch="$1"
  shift
  git send-email \
    --cc-cmd="./scripts/get_maintainer.pl --norolestats $patch" \
    "$@" "$patch"
}

# Extract various archive formats
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.tar.zst)   tar --zstd -xf "$1" ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.txz)       tar xJf "$1"     ;;
      *.xz)        unxz "$1"        ;;
      *.zst)       unzstd "$1"      ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# NVM - Lazy load for faster shell startup (requires NVM installed at ~/.nvm)
nvm_lazy_load() {
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    nvm() {
      unset -f nvm node npm npx
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      nvm "$@"
    }
    node() {
      unset -f nvm node npm npx
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      node "$@"
    }
    npm() {
      unset -f nvm node npm npx
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      npm "$@"
    }
    npx() {
      unset -f nvm node npm npx
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      npx "$@"
    }
  fi
}
nvm_lazy_load

