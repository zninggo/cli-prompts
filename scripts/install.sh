#!/usr/bin/env bash
set -euo pipefail

TOOL="all"
FORCE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      TOOL="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="true"
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

case "$TOOL" in
  claude|codex|gemini|all) ;;
  *)
    echo "Invalid --tool value: $TOOL" >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

install_prompt_file() {
  local name="$1"
  local source="$2"
  local target="$3"

  if [[ ! -f "$source" ]]; then
    echo "Source file not found: $source" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" ]]; then
    local backup="$target.bak"
    cp "$target" "$backup"

    if [[ "$FORCE" != "true" ]]; then
      printf "%s target exists. Backup created at %s. Overwrite %s? [y/N] " "$name" "$backup" "$target"
      read -r answer
      case "$answer" in
        y|Y|yes|YES) ;;
        *)
          echo "Skipped $name"
          return
          ;;
      esac
    fi
  fi

  cp "$source" "$target"
  echo "Installed $name -> $target"
}

install_claude() {
  install_prompt_file "claude" "$REPO_ROOT/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
}

install_codex() {
  install_prompt_file "codex" "$REPO_ROOT/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
}

install_gemini() {
  install_prompt_file "gemini" "$REPO_ROOT/gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md"
}

case "$TOOL" in
  claude) install_claude ;;
  codex) install_codex ;;
  gemini) install_gemini ;;
  all)
    install_claude
    install_codex
    install_gemini
    ;;
esac
