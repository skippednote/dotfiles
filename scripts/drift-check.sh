#!/usr/bin/env bash
# Report where this machine has drifted from this repo.
#
# Every regression during the migration to Nix came from one pattern:
# changing a file the live system symlinks, without switching. The repo and
# the machine then disagree, silently, because nothing looks. Specifically:
#
#   - untracking .config/gh/config.yml left ~/.config/gh/config.yml pointing
#     at a deleted target, and gh refused to write its config
#   - renaming home/.ssh/config to config-skippednote left ~/.ssh/config
#     dangling, so ssh fell back to defaults and the 1Password agent went
#     unused - it still "worked", just not as configured
#   - moving the signing block into host.conf left git's include pointing at
#     a file home-manager had not created yet, and three commits went
#     unsigned without a word
#
# Each was invisible until something else broke. This is the check that
# would have caught all three.
#
# Modelled on ~/selfhost/scripts/drift-check.sh on skippedbook, which does
# the same job for that repo. Notification is deliberately not handled here:
# this exits non-zero and prints, so a launchd agent or that repo's
# notify.sh can decide what to do with it.
set -uo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
HOST=$(scutil --get LocalHostName)
cd "$REPO" || exit 2

FAIL=0
note() { printf '  %s\n' "$1"; }
fail() {
  printf '  DRIFT: %s\n' "$1"
  FAIL=1
}

echo "drift-check: $HOST"

# 1. Files the live system writes back into the worktree. Expected
#    occasionally - lazy-lock.json, 1Password's ssh block - but it should be
#    a decision, not a surprise.
dirty=$(git status --porcelain 2>/dev/null)
if [ -n "$dirty" ]; then
  fail "uncommitted changes in the worktree"
  printf '%s\n' "$dirty" | sed 's/^/    /'
else
  note "worktree clean"
fi

# 2. Unpushed or unpulled commits. A machine running config that exists
#    nowhere else is a machine you cannot rebuild.
if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
  git fetch -q origin 2>/dev/null || note "could not fetch (offline?)"
  read -r behind ahead < <(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
  [ "${ahead:-0}" -gt 0 ] && fail "$ahead commit(s) not pushed"
  [ "${behind:-0}" -gt 0 ] && fail "$behind commit(s) not pulled"
  [ "${ahead:-0}" -eq 0 ] && [ "${behind:-0}" -eq 0 ] && note "in sync with origin"
else
  note "no upstream configured"
fi

# 3. The machine is running an older generation than the repo describes.
#    This is the "you edited a module and forgot to switch" case.
if command -v nix >/dev/null 2>&1; then
  want=$(nix eval --raw ".#darwinConfigurations.$HOST.config.system.build.toplevel" 2>/dev/null)
  have=$(readlink /run/current-system 2>/dev/null)
  if [ -z "$want" ]; then
    fail "cannot evaluate darwinConfigurations.$HOST"
  elif [ "$want" != "$have" ]; then
    fail "running generation differs from the repo - run 'make switch'"
    note "  want $want"
    note "  have $have"
  else
    note "running generation matches the repo"
  fi
else
  note "nix not on PATH; skipped generation check"
fi

# 4. Dangling home-manager links. This is the failure mode that bit three
#    times: a link whose target was renamed or deleted in the repo.
broken=0
while IFS= read -r link; do
  [ -e "$link" ] || { fail "dangling link: ${link/#$HOME/~}"; broken=$((broken + 1)); }
# The prune must precede -type l. Written the other way round the type test
# is evaluated first, is false for a directory, and short-circuits before
# -prune is ever reached - so the exclusion silently did nothing and this
# walked ~6,800 entries to answer a question about ~24 links. On skippedbook
# that included an 85 GiB OrbStack mount and the check wedged for 2h19m at
# zero CPU, having never once completed.
done < <(find -L "$HOME" -maxdepth 4 \
  \( -path "$HOME/Library" -o -path "$HOME/.local/state" -o -path "$HOME/OrbStack" \
     -o -path "$HOME/Movies" -o -path "$HOME/Music" -o -path "$HOME/Pictures" \) -prune \
  -o -type l -print 2>/dev/null |
  while read -r l; do
    case "$(readlink "$l" 2>/dev/null)" in /nix/store/*) echo "$l" ;; esac
  done)
[ "$broken" -eq 0 ] && note "no dangling nix-store links"

# 5. nix/packages/atuin.nix exists only because nixpkgs cannot build 18.21
#    yet (it needs rustc 1.98). Nothing otherwise notices when that stops
#    being true, and a hand-pinned hash is a maintenance cost worth dropping
#    the moment it is unnecessary.
if command -v nix >/dev/null 2>&1; then
  ours=$(sed -n 's/.*version = "\(.*\)";/\1/p' "$REPO/nix/packages/atuin.nix" | head -1)
  # Evaluate the flake's own locked nixpkgs. `nixpkgs#` resolves to whatever
  # the registry points at - on Determinate that is a weekly channel this
  # config does not use - so the old form asked about the wrong tree.
  theirs=$(nix eval --raw ".#darwinConfigurations.$HOST.pkgs.atuin.version" 2>/dev/null)
  # >= rather than =, or a bump straight to 18.22 would read "still pinned"
  # forever and the file would never be retired.
  if [ -n "$theirs" ] &&
    [ "$(printf '%s\n%s\n' "$ours" "$theirs" | sort -V | tail -1)" = "$theirs" ]; then
    fail "nixpkgs now has atuin $theirs - delete nix/packages/atuin.nix and use pkgs.atuin"
  else
    note "atuin still pinned ($ours; nixpkgs has ${theirs:-?})"
  fi
fi

exit "$FAIL"
