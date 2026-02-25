#!/bin/bash
# Dedup Check — Filter candidate names against existing domain lists
# Bash 3.2 compatible (macOS default)
#
# Usage:
#   bash dedup-check.sh name1 name2 name3
#   echo "name1 name2 name3" | bash dedup-check.sh
#
# Output (tty):
#   NEW: brandnew, othernew
#   SKIP (available): matchfolk, trovavi
#   SKIP (taken): sadaa, pertino
#
# Output (pipe / --pipe):
#   brandnew
#   othernew
#
# Pipe-friendly:
#   bash dedup-check.sh name1 name2 name3 | bash check-domains.sh

set -euo pipefail

# ── Paths (portable — uses DOMAIN_TRACK_DIR or current directory) ─────────────
TRACK_DIR="${DOMAIN_TRACK_DIR:-.}"
AVAILABLE_FILE="$TRACK_DIR/tasks/domains-available.md"
TAKEN_FILE="$TRACK_DIR/tasks/domains-taken.md"
REJECTED_FILE="$TRACK_DIR/tasks/domains-rejected.md"

# ── Defaults ─────────────────────────────────────────────────────────────────
PIPE_MODE=0

# Auto-detect pipe mode when stdout is not a tty
if [ ! -t 1 ]; then
  PIPE_MODE=1
fi

# ── Colors (only when not piping) ────────────────────────────────────────────
setup_colors() {
  if [ "$PIPE_MODE" -eq 1 ]; then
    C_RESET="" C_GREEN="" C_RED="" C_YELLOW="" C_CYAN="" C_BOLD="" C_DIM=""
  else
    C_RESET='\033[0m'
    C_GREEN='\033[0;32m'
    C_RED='\033[0;31m'
    C_YELLOW='\033[0;33m'
    C_CYAN='\033[0;36m'
    C_BOLD='\033[1m'
    C_DIM='\033[2m'
  fi
}

# ── Helpers ──────────────────────────────────────────────────────────────────
usage() {
  cat <<'USAGE'
Dedup Check — Filter candidates against existing domain lists

Usage:
  bash dedup-check.sh [OPTIONS] name1 [name2 ...]
  echo "name1 name2" | bash dedup-check.sh [OPTIONS]

Environment:
  DOMAIN_TRACK_DIR    Base directory for tracking files (default: current dir)

Options:
  --pipe        Force pipe-friendly output (one new name per line, no labels)
  --help        Show this help

Checks candidate names against:
  - tasks/domains-available.md  (WHOIS-confirmed available)
  - tasks/domains-taken.md      (confirmed taken)
  - tasks/domains-rejected.md   (failed brand review)

Uses exact word-boundary matching (case-insensitive).
"apple" does NOT match "pineapple".

Pipe example:
  bash dedup-check.sh name1 name2 name3 | bash check-domains.sh
USAGE
  exit 0
}

# Extract names from a markdown table file (first column after |)
# Skips header rows (containing "Name" or "---")
extract_names() {
  local file="$1"
  if [ ! -f "$file" ]; then
    return
  fi
  awk -F'|' '
    /^\|/ && !/Name/ && !/---/ {
      name = $2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
      if (name != "") print tolower(name)
    }
  ' "$file"
}

# ── Parse arguments ──────────────────────────────────────────────────────────
CANDIDATES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --pipe)     PIPE_MODE=1;  shift ;;
    --help|-h)  usage ;;
    --)         shift; break ;;
    -*)         echo "Unknown option: $1" >&2; exit 1 ;;
    *)          CANDIDATES+=("$1"); shift ;;
  esac
done

# Remaining args after --
while [ $# -gt 0 ]; do
  CANDIDATES+=("$1")
  shift
done

# Read from stdin if no args and stdin is not a tty
if [ ${#CANDIDATES[@]} -eq 0 ] && [ ! -t 0 ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    for word in $line; do
      CANDIDATES+=("$word")
    done
  done
fi

if [ ${#CANDIDATES[@]} -eq 0 ]; then
  echo "Error: No candidate names provided." >&2
  echo "Run with --help for usage." >&2
  exit 1
fi

# ── Load existing names ─────────────────────────────────────────────────────
AVAILABLE_NAMES=$(extract_names "$AVAILABLE_FILE")
TAKEN_NAMES=$(extract_names "$TAKEN_FILE")
REJECTED_NAMES=$(extract_names "$REJECTED_FILE")

# ── Check each candidate ────────────────────────────────────────────────────
NEW_NAMES=()
SKIP_AVAILABLE=()
SKIP_TAKEN=()
SKIP_REJECTED=()

for candidate in "${CANDIDATES[@]}"; do
  # Normalize: lowercase, trim whitespace
  name=$(printf '%s' "$candidate" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

  # Skip empty
  [ -z "$name" ] && continue

  # Check against available list (exact word-boundary match)
  if printf '%s\n' "$AVAILABLE_NAMES" | grep -qiw "$name"; then
    SKIP_AVAILABLE+=("$name")
  elif printf '%s\n' "$TAKEN_NAMES" | grep -qiw "$name"; then
    SKIP_TAKEN+=("$name")
  elif printf '%s\n' "$REJECTED_NAMES" | grep -qiw "$name"; then
    SKIP_REJECTED+=("$name")
  else
    NEW_NAMES+=("$name")
  fi
done

# ── Output ───────────────────────────────────────────────────────────────────
setup_colors

if [ "$PIPE_MODE" -eq 1 ]; then
  # Pipe mode: only output new names, one per line
  for name in ${NEW_NAMES[@]+"${NEW_NAMES[@]}"}; do
    printf '%s\n' "$name"
  done
else
  # Interactive mode: show all categories
  if [ ${#NEW_NAMES[@]} -gt 0 ]; then
    printf "${C_GREEN}${C_BOLD}NEW:${C_RESET} %s\n" "$(IFS=', '; echo "${NEW_NAMES[*]}")"
  fi

  if [ ${#SKIP_AVAILABLE[@]} -gt 0 ]; then
    printf "${C_CYAN}SKIP (available):${C_RESET} %s\n" "$(IFS=', '; echo "${SKIP_AVAILABLE[*]}")"
  fi

  if [ ${#SKIP_TAKEN[@]} -gt 0 ]; then
    printf "${C_RED}SKIP (taken):${C_RESET} %s\n" "$(IFS=', '; echo "${SKIP_TAKEN[*]}")"
  fi

  if [ ${#SKIP_REJECTED[@]} -gt 0 ]; then
    printf "${C_YELLOW}SKIP (rejected):${C_RESET} %s\n" "$(IFS=', '; echo "${SKIP_REJECTED[*]}")"
  fi

  if [ ${#NEW_NAMES[@]} -eq 0 ]; then
    printf "${C_DIM}No new names to check.${C_RESET}\n"
  fi
fi
