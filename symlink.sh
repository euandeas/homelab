#!/bin/bash

SOURCE_DIR="$(dirname "$(realpath "$0")")"
TARGET_DIR="$HOME/.config/containers/systemd"

mkdir -p "$TARGET_DIR"

for dir in "$SOURCE_DIR"/*; do
    if [ -d "$dir" ]; then
        ln -s "$dir" "$TARGET_DIR/$(basename "$dir")"
        echo "Symlinked: $dir -> $TARGET_DIR/$(basename "$dir")"
    fi
done

echo "All child directories of $SOURCE_DIR have been symlinked to $TARGET_DIR."

TARGET_DIR="$(dirname "$(realpath "$0")")/storage"
SOURCE_DIR="$HOME/.local/share/containers/storage/volumes/"

ln -s "$SOURCE_DIR" "$TARGET_DIR"
echo "Symlinked: $SOURCE_DIR -> $TARGET_DIR"
