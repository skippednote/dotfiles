#!/usr/bin/env bash
# Run drift-check.sh and alert only when the answer changes.
#
# Mirrors ~/selfhost/scripts/drift-check.sh on skippedbook, which alerts on
# state change rather than on every run - a daily "still clean" message is
# noise nobody reads, and noise is how a real alert gets missed.
#
# Notification goes through selfhost's notify.sh because that is where the
# Telegram credentials live; no secret belongs in this repo. If that script
# is absent - as on skippednote - this still runs and just prints, so the
# same agent definition is safe anywhere.
set -uo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
NOTIFY="$HOME/selfhost/scripts/notify.sh"
STATE="$HOME/.local/state/dotfiles-drift"
HOST=$(scutil --get LocalHostName)

mkdir -p "$(dirname "$STATE")"

out=$(bash "$REPO/scripts/drift-check.sh" 2>&1)
rc=$?
prev=$(cat "$STATE" 2>/dev/null || echo clean)
# Hash the actual DRIFT lines rather than a clean/drifted flag. With a flag,
# one long-lived problem - an expected writeback like lazy-lock.json - latches
# the state and a genuinely new failure arriving later produces no alert at
# all, because the flag never changes.
drifts=$(printf '%s\n' "$out" | grep '^  DRIFT:' || true)
if [ -z "$drifts" ]; then
  cur=clean
else
  cur=$(printf '%s' "$drifts" | shasum | cut -d" " -f1)
fi

printf '%s\n' "$out"
printf '%s' "$cur" >"$STATE"

[ "$cur" = "$prev" ] && exit "$rc"

if [ -x "$NOTIFY" ] || [ -f "$NOTIFY" ]; then
  if [ "$cur" != "clean" ]; then
    bash "$NOTIFY" "dotfiles drifted on $HOST" "$out" 2>/dev/null || true
  else
    bash "$NOTIFY" "dotfiles clean on $HOST" "Back in sync with the repo." 2>/dev/null || true
  fi
fi

exit "$rc"
