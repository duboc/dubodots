#!/bin/bash
set -e

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "======================================================="
echo "Starting Dotfiles Installation"
echo "======================================================="

OS="$(uname -s)"

case "$OS" in
    Darwin)
        echo "Detected OS: macOS ($(uname -m))"
        echo "Running macOS setup..."
        if [ -f "$SCRIPT_DIR/setup_mac.sh" ]; then
            bash "$SCRIPT_DIR/setup_mac.sh"
        else
            echo "Error: setup_mac.sh not found." >&2
            exit 1
        fi
        ;;
    Linux)
        echo "Detected OS: Linux ($(uname -m))"
        echo "Running Linux setup..."
        if [ -f "$SCRIPT_DIR/setup_linux.sh" ]; then
            bash "$SCRIPT_DIR/setup_linux.sh"
        else
            echo "Error: setup_linux.sh not found." >&2
            exit 1
        fi
        ;;
    *)
        echo "Unsupported operating system: $OS" >&2
        exit 1
        ;;
esac

echo ""
echo "======================================================="
echo "Dotfiles installation completed successfully!"
echo "Please restart your terminal session to apply all changes."
echo "======================================================="
