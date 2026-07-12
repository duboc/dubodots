#!/bin/bash
# Install Go apps using modern 'go install' syntax

if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$(go env GOPATH 2>/dev/null || echo "$HOME/go")/bin:$PATH"

# Only run if Go is present
if command -v go &>/dev/null; then

    # Github Hub
    echo "Installing Github hub..."
    go install github.com/github/hub@latest || true

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
