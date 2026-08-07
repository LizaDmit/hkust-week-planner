#!/bin/bash
# Re-scrapes the catalogue. Run by hand, or on a schedule via install-schedule.sh.

TERM_CODE=2610          # 2026-27 Fall. Change when the term rolls over.

cd "$(dirname "$0")" || exit 1
mkdir -p logs

{
  echo "=== $(date) ==="
  python3 scrape.py --term "$TERM_CODE" --subjects all --delay 2
  echo
} >> logs/refresh.log 2>&1

# scrape.py exits before writing if it parsed nothing, so a failed run
# leaves the previous data/ untouched rather than blanking it.
tail -n 40 logs/refresh.log
