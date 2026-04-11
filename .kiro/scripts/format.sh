#!/bin/bash
# Format - auto-format a file using detected formatter
# Detects: biome or prettier
# Used by: .kiro/hooks/auto-format.kiro.hook (fileEdited)

set -o pipefail

if [ -z "$1" ]; then
  echo "Usage: format.sh <file>"
  exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "Error: File not found: $FILE"
  exit 1
fi

detect_formatter() {
  if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then echo "biome"
  elif [ -f ".prettierrc" ] || [ -f ".prettierrc.js" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then echo "prettier"
  elif command -v biome &>/dev/null; then echo "biome"
  elif command -v prettier &>/dev/null; then echo "prettier"
  else echo "none"; fi
}

FORMATTER=$(detect_formatter)

case "$FORMATTER" in
  biome)
    if command -v npx &>/dev/null; then
      echo "Formatting $FILE with Biome..."
      npx biome format --write "$FILE"
    else
      echo "Error: npx not found"; exit 1
    fi
    ;;
  prettier)
    if command -v npx &>/dev/null; then
      echo "Formatting $FILE with Prettier..."
      npx prettier --write "$FILE"
    else
      echo "Error: npx not found"; exit 1
    fi
    ;;
  none)
    echo "No formatter detected. Skipping: $FILE"
    exit 0
    ;;
esac
