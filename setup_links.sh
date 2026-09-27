#!/bin/bash

echo "Setting links to dotfiles in home directory: $HOME"

create_link() {
  origin="$1"
  dest="$2"
  echo "Linking: $origin -> $dest"

  if [[ -e "$dest" ]] && [[ ! -L "$dest" ]]; then
      echo "  Destination ($dest) already exists as a non-symlink file/directory. Backup to $dest-old"
      mv "$dest" "$dest-old"
  fi
  ln -sfn "$origin" "$dest"
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure ~/.dotfiles points to this repository if cloned elsewhere
if [ "$SCRIPT_DIR" != "$HOME/.dotfiles" ]; then
  create_link "$SCRIPT_DIR" "$HOME/.dotfiles"
fi

# Link .rc files
for FILE in "$SCRIPT_DIR/rc/"*; do
  filename="$(basename "$FILE")"
  if [ "$filename" = "config" ] && [ -d "$FILE" ]; then
      echo "Handling ~/.config directory contents..."
      mkdir -p "$HOME/.config"
      for SUBITEM in "$FILE/"*; do
          [ -e "$SUBITEM" ] || continue
          subname="$(basename "$SUBITEM")"
          create_link "$SUBITEM" "$HOME/.config/$subname"
      done
  else
      create_link "$FILE" "$HOME/.$filename"
  fi
done

# On macOS, Ghostty also reads ~/Library/Application Support/com.mitchellh.ghostty/config.ghostty
if [ "$(uname -s)" = "Darwin" ] && [ -f "$SCRIPT_DIR/rc/config/ghostty/config" ]; then
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  create_link "$SCRIPT_DIR/rc/config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
fi

# Remove dangling symlinks that point into this repo (configs removed from dotfiles, e.g. ~/.config/jj)
for LINK in "$HOME"/.[!.]* "$HOME/.config"/*; do
  if [ -L "$LINK" ] && [ ! -e "$LINK" ]; then
    case "$(readlink "$LINK")" in
      "$SCRIPT_DIR"/*|"$HOME/.dotfiles"/*)
        echo "Removing stale link: $LINK"
        rm "$LINK"
        ;;
    esac
  fi
done

echo "Link setup complete."