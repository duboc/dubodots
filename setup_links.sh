#!/bin/bash

echo "Setting links to dotfiles on user home dir: $HOME"

create_link() {
  origin=$1
  dest=$2
  echo Linking origin file "$origin" to destination "$dest"

  if [[ -f "$dest" || -d "$dest" ]] && [ ! -L "$dest" ]; then
      echo "Destination ($dest) already exists. Renaming to $dest-old"
      mv "$dest" "$dest-old"
  fi
  ln -sfn "$origin" "$dest"
}

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Link .rc files
for FILE in "$SCRIPT_DIR/rc/"*
do
  create_link "$FILE" "$HOME/.$(basename "$FILE")"
done