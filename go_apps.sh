#!/bin/bash
# Install Go apps using modern 'go install' syntax

if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Include /usr/local/go/bin if present
if [ -d "/usr/local/go/bin" ]; then
    export PATH="/usr/local/go/bin:$PATH"
fi

export PATH="$(go env GOPATH 2>/dev/null || echo "$HOME/go")/bin:$PATH"

# Only run if Go is present
if command -v go &>/dev/null; then

    # Command line two-factor authentication
    echo "Installing 2fa..."
    go install rsc.io/2fa@latest || true

    # benchstat - tool to compare benchmarks
    echo "Installing benchstat..."
    go install golang.org/x/perf/cmd/benchstat@latest || true

    # Yaegi - Go command line interpreter
    echo "Installing yaegi..."
    go install github.com/traefik/yaegi/cmd/yaegi@latest || true
else
    echo "Go is not installed or not in PATH. Skipping Go apps setup."
fi

