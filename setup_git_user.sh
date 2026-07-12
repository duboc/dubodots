#!/bin/bash

# Setup Git User Identity interactively, preserving existing setup or prompting user

GITCONFIG_LOCAL="$HOME/.gitconfig.local"

# Detect current git name & email if set globally
CURRENT_NAME="$(git config --global user.name 2>/dev/null || true)"
CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

# If ~/.gitconfig.local already exists, extract values from it if set
if [ -f "$GITCONFIG_LOCAL" ]; then
    LOCAL_NAME="$(git config --file "$GITCONFIG_LOCAL" user.name 2>/dev/null || true)"
    LOCAL_EMAIL="$(git config --file "$GITCONFIG_LOCAL" user.email 2>/dev/null || true)"
    [ -n "$LOCAL_NAME" ] && CURRENT_NAME="$LOCAL_NAME"
    [ -n "$LOCAL_EMAIL" ] && CURRENT_EMAIL="$LOCAL_EMAIL"
fi

if [ -t 0 ]; then
    echo "======================================================="
    echo "Configuring Git User Identity"
    echo "======================================================="

    read -p "Enter your Git Full Name [${CURRENT_NAME:-Not set}]: " INPUT_NAME
    FINAL_NAME="${INPUT_NAME:-$CURRENT_NAME}"

    read -p "Enter your Git Email [${CURRENT_EMAIL:-Not set}]: " INPUT_EMAIL
    FINAL_EMAIL="${INPUT_EMAIL:-$CURRENT_EMAIL}"

    if [ -n "$FINAL_NAME" ] || [ -n "$FINAL_EMAIL" ]; then
        touch "$GITCONFIG_LOCAL"
        [ -n "$FINAL_NAME" ] && git config --file "$GITCONFIG_LOCAL" user.name "$FINAL_NAME"
        [ -n "$FINAL_EMAIL" ] && git config --file "$GITCONFIG_LOCAL" user.email "$FINAL_EMAIL"
        echo "Git identity updated in $GITCONFIG_LOCAL."
    fi
    echo ""
else
    # Non-interactive mode: create ~/.gitconfig.local if missing, saving current values if set
    if [ ! -f "$GITCONFIG_LOCAL" ]; then
        touch "$GITCONFIG_LOCAL"
        [ -n "$CURRENT_NAME" ] && git config --file "$GITCONFIG_LOCAL" user.name "$CURRENT_NAME"
        [ -n "$CURRENT_EMAIL" ] && git config --file "$GITCONFIG_LOCAL" user.email "$CURRENT_EMAIL"
    fi
fi

exit 0
