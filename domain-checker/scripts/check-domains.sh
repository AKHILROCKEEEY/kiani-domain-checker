#!/bin/bash
# Domain Availability Checker — 3-Stage Pipeline (DNS → WHOIS)
# Bash 3.2 compatible (macOS default)
#
# Usage:
#   bash check-domains.sh domain1.com domain2.com
#   bash check-domains.sh matchfolk sadaa pertino       # auto-appends .com
#   echo "matchfolk sadaa pertino" | bash check-domains.sh
#   bash check-domains.sh --dns-only domain1 domain2    # skip WHOIS
#   bash check-domains.sh --plain domain1 domain2       # tab-separated output

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
WHOIS_DELAY=2
DNS_ONLY=0
PLAIN=0

# ── Colors (auto-detect tty) ─────────────────────────────────────────────────
setup_colors() {
  if [ "$PLAIN" -eq 1 ] || [ ! -t 1 ]; then
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

# ── Helpers ───────────────────────────────────────────────────────────────────
normalize_domain() {
  local d
  d=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
  # auto-append .com if no TLD
  case "$d" in
    *.*) ;;
    *)   d="${d}.com" ;;
  esac
  printf '%s' "$d"
}

usage() {
  cat <<'USAGE'
Domain Checker (DNS → WHOIS pipeline)

Usage:
  bash check-domains.sh [OPTIONS] domain1 [domain2 ...]
  echo "domain1 domain2" | bash check-domains.sh [OPTIONS]

Options:
  --plain       Tab-separated output, no colors (for piping)
  --delay N     Seconds between WHOIS queries (default: 2)
  --dns-only    DNS pass only, skip WHOIS confirmation
  --help        Show this help

Domains without a TLD automatically get .com appended.
USAGE
  exit 0
}

# ── DNS Check ─────────────────────────────────────────────────────────────────
# Returns: 0 = resolves (TAKEN), 1 = NXDOMAIN (needs WHOIS), 2 = error
check_dns() {
  local domain="$1"
  local output
  output=$(host "$domain" 2>&1) || true

  if printf '%s' "$output" | grep -qi "has address\|has IPv6 address\|mail is handled"; then
    # Resolves — definitely taken
    local ip
    ip=$(printf '%s' "$output" | grep -i "has address" | head -1 | awk '{print $NF}')
    DNS_IP="$ip"
    return 0
  elif printf '%s' "$output" | grep -qi "NXDOMAIN\|not found\|has no"; then
    # NXDOMAIN — needs WHOIS to confirm
    DNS_IP=""
    return 1
  else
    # NOERROR with zero answers (registered but no DNS configured) — needs WHOIS
    DNS_IP=""
    return 1
  fi
}

# ── WHOIS Check ───────────────────────────────────────────────────────────────
# Returns: 0 = available, 1 = taken, 2 = rate limited / error
check_whois() {
  local domain="$1"
  local result
  result=$(whois "$domain" 2>/dev/null) || true

  # Check for rate limiting first
  if printf '%s' "$result" | grep -qi "rate limit\|too many\|try again later\|quota exceeded"; then
    WHOIS_DETAIL="Rate limited"
    return 2
  fi

  # Check for availability signals
  if printf '%s' "$result" | grep -qi "no match\|not found\|no data found\|domain not found\|^available\|no entries found\|no object found"; then
    WHOIS_DETAIL="No match"
    return 0
  fi

  # Extract metadata for taken domains
  local expiry registrar
  expiry=$(printf '%s' "$result" | grep -i "expir\|paid-till" | head -1 | sed 's/.*: *//' | tr -d '[:space:]' | cut -c1-20)
  registrar=$(printf '%s' "$result" | grep -i "registrar:" | head -1 | sed 's/.*: *//' | cut -c1-30 | sed 's/[[:space:]]*$//')

  if [ -n "$expiry" ] && [ -n "$registrar" ]; then
    WHOIS_DETAIL="Exp ${expiry} / ${registrar}"
  elif [ -n "$expiry" ]; then
    WHOIS_DETAIL="Exp ${expiry}"
  elif [ -n "$registrar" ]; then
    WHOIS_DETAIL="${registrar}"
  else
    WHOIS_DETAIL="Registered"
  fi
  return 1
}

# ── Output ────────────────────────────────────────────────────────────────────
print_result() {
  local domain="$1" status="$2" stage="$3" details="$4"

  if [ "$PLAIN" -eq 1 ]; then
    printf '%s\t%s\t%s\t%s\n' "$domain" "$status" "$stage" "$details"
    return
  fi

  local color
  case "$status" in
    AVAILABLE)    color="$C_GREEN" ;;
    TAKEN)        color="$C_RED" ;;
    RATE_LIMITED) color="$C_YELLOW" ;;
    *)            color="$C_DIM" ;;
  esac

  printf "  %-32s ${color}%-14s${C_RESET} ${C_DIM}%-12s${C_RESET} %s\n" \
    "$domain" "$status" "$stage" "$details"
}

print_header() {
  if [ "$PLAIN" -eq 1 ]; then
    printf 'DOMAIN\tSTATUS\tSTAGE\tDETAILS\n'
    return
  fi
  printf "\n${C_BOLD}  Domain Checker (DNS → WHOIS)${C_RESET}\n"
  printf "  ════════════════════════════════════════════════════════\n\n"
  printf "  ${C_BOLD}%-32s %-14s %-12s %s${C_RESET}\n" "DOMAIN" "STATUS" "STAGE" "DETAILS"
  printf "  ${C_DIM}%-32s %-14s %-12s %s${C_RESET}\n" "------" "------" "-----" "-------"
}

print_summary() {
  local total="$1" available="$2" taken="$3" failed="$4"
  if [ "$PLAIN" -eq 1 ]; then
    printf '\n%s checked | %s AVAILABLE | %s TAKEN | %s FAILED\n' \
      "$total" "$available" "$taken" "$failed"
    return
  fi
  printf "\n  ════════════════════════════════════════════════════════\n"
  printf "  ${C_BOLD}%s${C_RESET} checked" "$total"
  printf " | ${C_GREEN}%s AVAILABLE${C_RESET}" "$available"
  printf " | ${C_RED}%s TAKEN${C_RESET}" "$taken"
  if [ "$failed" -gt 0 ]; then
    printf " | ${C_YELLOW}%s FAILED${C_RESET}" "$failed"
  fi
  printf "\n  ════════════════════════════════════════════════════════\n\n"
}

# ── Parse arguments ───────────────────────────────────────────────────────────
DOMAINS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --plain)    PLAIN=1;       shift ;;
    --delay)    WHOIS_DELAY="$2"; shift 2 ;;
    --dns-only) DNS_ONLY=1;    shift ;;
    --help|-h)  usage ;;
    --)         shift; break ;;
    -*)         echo "Unknown option: $1" >&2; exit 1 ;;
    *)          DOMAINS+=("$1"); shift ;;
  esac
done

# Remaining args after --
while [ $# -gt 0 ]; do
  DOMAINS+=("$1")
  shift
done

# Read from stdin if no domain args and stdin is not a tty
if [ ${#DOMAINS[@]} -eq 0 ] && [ ! -t 0 ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    for word in $line; do
      DOMAINS+=("$word")
    done
  done
fi

if [ ${#DOMAINS[@]} -eq 0 ]; then
  echo "Error: No domains provided." >&2
  echo "Run with --help for usage." >&2
  exit 1
fi

# ── Deduplicate & normalize ───────────────────────────────────────────────────
NORMALIZED=()
SEEN=""
for raw in "${DOMAINS[@]}"; do
  d=$(normalize_domain "$raw")
  # Simple dedup using string matching (bash 3.2 compatible)
  case "$SEEN" in
    *"|${d}|"*) continue ;;
  esac
  SEEN="${SEEN}|${d}|"
  NORMALIZED+=("$d")
done

# ── Setup ─────────────────────────────────────────────────────────────────────
setup_colors
print_header

COUNT_TOTAL=${#NORMALIZED[@]}
COUNT_AVAILABLE=0
COUNT_TAKEN=0
COUNT_FAILED=0

DNS_IP=""
WHOIS_DETAIL=""

# ── Pipeline ──────────────────────────────────────────────────────────────────
# Stage 1: DNS for all domains (fast, no rate limit)
# Stage 2: WHOIS only for NXDOMAIN results (slow, rate limited)

WHOIS_QUEUE=()

for domain in "${NORMALIZED[@]}"; do
  check_dns "$domain" && dns_result=0 || dns_result=$?

  if [ $dns_result -eq 0 ]; then
    # DNS resolves → definitely taken
    print_result "$domain" "TAKEN" "DNS" "Resolves to ${DNS_IP}"
    COUNT_TAKEN=$((COUNT_TAKEN + 1))
  elif [ $dns_result -eq 1 ]; then
    # NXDOMAIN → needs WHOIS
    if [ "$DNS_ONLY" -eq 1 ]; then
      print_result "$domain" "AVAILABLE?" "DNS" "NXDOMAIN (WHOIS skipped)"
      COUNT_AVAILABLE=$((COUNT_AVAILABLE + 1))
    else
      WHOIS_QUEUE+=("$domain")
    fi
  else
    # DNS error
    print_result "$domain" "ERROR" "DNS" "Lookup failed"
    COUNT_FAILED=$((COUNT_FAILED + 1))
  fi
done

# Stage 2: WHOIS for unresolved domains
WHOIS_COUNT=0
for domain in ${WHOIS_QUEUE[@]+"${WHOIS_QUEUE[@]}"}; do
  # Rate limit delay (skip before first query)
  if [ $WHOIS_COUNT -gt 0 ]; then
    sleep "$WHOIS_DELAY"
  fi
  WHOIS_COUNT=$((WHOIS_COUNT + 1))

  check_whois "$domain" && whois_result=0 || whois_result=$?

  if [ $whois_result -eq 0 ]; then
    # WHOIS says available
    print_result "$domain" "AVAILABLE" "DNS+WHOIS" "$WHOIS_DETAIL"
    COUNT_AVAILABLE=$((COUNT_AVAILABLE + 1))
  elif [ $whois_result -eq 1 ]; then
    # WHOIS says taken (parked domain, no DNS)
    print_result "$domain" "TAKEN" "DNS+WHOIS" "Parked: ${WHOIS_DETAIL}"
    COUNT_TAKEN=$((COUNT_TAKEN + 1))
  else
    # Rate limited or error
    print_result "$domain" "RATE_LIMITED" "WHOIS" "$WHOIS_DETAIL"
    COUNT_FAILED=$((COUNT_FAILED + 1))
  fi
done

# ── Summary ───────────────────────────────────────────────────────────────────
print_summary "$COUNT_TOTAL" "$COUNT_AVAILABLE" "$COUNT_TAKEN" "$COUNT_FAILED"
