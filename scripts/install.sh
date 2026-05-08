#!/usr/bin/env bash
set -euo pipefail

TOOL="all"
MODE="merge"
FORCE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      TOOL="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
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

case "$MODE" in
  merge|overwrite) ;;
  *)
    echo "Invalid --mode value: $MODE" >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

backup_target_file() {
  local target="$1"
  local backup="$target.bak"
  cp "$target" "$backup"
  printf '%s' "$backup"
}

write_managed_prompt_file() {
  local name="$1"
  local source="$2"
  local target="$3"
  local begin_marker="<!-- BEGIN cli-prompts:$name -->"
  local end_marker="<!-- END cli-prompts:$name -->"

  printf '%s\n' "$begin_marker" > "$target"
  cat "$source" >> "$target"
  printf '\n%s\n' "$end_marker" >> "$target"
}

merge_prompt_file() {
  local name="$1"
  local source="$2"
  local target="$3"
  local begin_marker="<!-- BEGIN cli-prompts:$name -->"
  local end_marker="<!-- END cli-prompts:$name -->"
  local temp_file
  temp_file="$(mktemp)"

  if grep -Fq "$begin_marker" "$target" && ! grep -Fq "$end_marker" "$target"; then
    echo "Managed block end marker not found in $target" >&2
    rm -f "$temp_file"
    exit 1
  fi

  if ! grep -Fq "$begin_marker" "$target" && grep -Fq "$end_marker" "$target"; then
    echo "Managed block begin marker not found in $target" >&2
    rm -f "$temp_file"
    exit 1
  fi

  if grep -Fq "$begin_marker" "$target"; then
    awk -v begin="$begin_marker" -v end="$end_marker" -v source="$source" '
      $0 == begin {
        print begin
        while ((getline line < source) > 0) print line
        close(source)
        print end
        in_block = 1
        next
      }
      $0 == end {
        in_block = 0
        next
      }
      !in_block { print }
    ' "$target" > "$temp_file"
  else
    cp "$target" "$temp_file"
    if [[ -s "$temp_file" ]]; then
      printf '\n' >> "$temp_file"
    fi
    printf '%s\n' "$begin_marker" >> "$temp_file"
    cat "$source" >> "$temp_file"
    printf '\n%s\n' "$end_marker" >> "$temp_file"
  fi

  mv "$temp_file" "$target"
}

install_prompt_file() {
  local name="$1"
  local source="$2"
  local target="$3"

  if [[ ! -f "$source" ]]; then
    echo "Source file not found: $source" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target")"

  if [[ ! -f "$target" ]]; then
    if [[ "$MODE" == "merge" ]]; then
      write_managed_prompt_file "$name" "$source" "$target"
    else
      cp "$source" "$target"
    fi

    echo "Installed $name -> $target"
    return
  fi

  local backup
  backup="$(backup_target_file "$target")"

  if [[ "$MODE" == "overwrite" ]]; then
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

    cp "$source" "$target"
    echo "Overwrote $name -> $target"
    return
  fi

  merge_prompt_file "$name" "$source" "$target"
  echo "Merged $name -> $target"
  echo "Backup: $backup"
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
