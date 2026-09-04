#!/usr/bin/env bash
# Harness for bootstrap.sh: simulates machine states with stub binaries and
# asserts what the script actually does. Run with `make test`.
#
# Every external command is stubbed, so this proves control flow - which
# branch runs under which machine state - not that the real installer,
# darwin-rebuild or sdkman behave as assumed. Both bugs it has caught so far
# were introduced by edits, which is when it earns its keep.
#
# Known gap: the sdkman bash-4 guard reads a hardcoded
# /etc/profiles/per-user/$(whoami)/bin/bash, which exists on a configured
# machine, so that branch cannot be reached from a stub PATH.
set -uo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=$(/usr/bin/mktemp -d)/bs
rm -rf "$BASE"; mkdir -p "$BASE"
PASS=0; FAIL=0

make_stubs() {
  local d="$1"; mkdir -p "$d"
  for c in curl sudo launchctl defaults; do
    printf '#!/bin/bash\necho "CALL: %s $*" >> "$CALLLOG"\nexit 0\n' "$c" > "$d/$c"
    chmod +x "$d/$c"
  done
  # bootstrap.sh derives the host from scutil, so the stub decides which host
  # each scenario is pretending to be.
  printf '#!/bin/bash\necho "%s"\n' "${FAKE_HOST:-skippednote}" > "$d/scutil"
  chmod +x "$d/scutil"
  if [ "${XCODE_PRESENT:-1}" = "0" ]; then
    printf '#!/bin/bash\necho "CALL: xcode-select $*" >> "$CALLLOG"\n[ "$1" = "-p" ] && exit 1\nexit 0\n' > "$d/xcode-select"
  else
    printf '#!/bin/bash\necho "CALL: xcode-select $*" >> "$CALLLOG"\nexit 0\n' > "$d/xcode-select"
  fi
  chmod +x "$d/xcode-select"
  if [ "${NIX_PRESENT:-1}" = "1" ]; then
    printf '#!/bin/bash\necho "CALL: nix $*" >> "$CALLLOG"\nexit 0\n' > "$d/nix"
    chmod +x "$d/nix"
  fi
  # a realistic installer: creates the profile script and the nix binary
  if [ "${INSTALLER_CREATES_PROFILE:-0}" = "1" ]; then
    cat > "$d/sh" <<EOF
#!/bin/bash
echo "CALL: sh \$*" >> "\$CALLLOG"
printf '#!/bin/bash\\n' > "$CASEDIR/nixprofile.sh"
printf '#!/bin/bash\\necho "CALL: nix \$*" >> "\$CALLLOG"\\nexit 0\\n' > "$CASEDIR/bin/nix"
chmod +x "$CASEDIR/bin/nix"
exit 0
EOF
    chmod +x "$d/sh"
  fi
}

assert() { # name, expect-present|expect-absent, pattern, file
  if [ "$2" = "present" ]; then
    if /usr/bin/grep -q "$3" "$4" 2>/dev/null; then echo "    PASS $1"; PASS=$((PASS+1));
    else echo "    FAIL $1 (expected '$3')"; FAIL=$((FAIL+1)); fi
  else
    if /usr/bin/grep -q "$3" "$4" 2>/dev/null; then echo "    FAIL $1 (unexpected '$3')"; FAIL=$((FAIL+1));
    else echo "    PASS $1"; PASS=$((PASS+1)); fi
  fi
}

run_case() {
  local name="$1"; local dir="$BASE/$name"
  mkdir -p "$dir/bin" "$dir/home"
  export CALLLOG="$dir/calls.log"; : > "$CALLLOG"
  CASEDIR="$dir" make_stubs "$dir/bin"
  sed "s|^NIX_PROFILE_SH=.*|NIX_PROFILE_SH=$dir/nixprofile.sh|" \
    "$REPO/bootstrap.sh" > "$dir/bootstrap.sh"
  chmod +x "$dir/bootstrap.sh"
  [ "${NIX_PROFILE:-0}" = "1" ] && printf '#!/bin/bash\n' > "$dir/nixprofile.sh"
  [ "${SDKMAN_PRESENT:-0}" = "1" ] && mkdir -p "$dir/home/.sdkman"
  ( export PATH="$dir/bin:/usr/bin:/bin"; export HOME="$dir/home"; cd "$dir"
    echo "" | ./bootstrap.sh > "$dir/out.log" 2>&1; echo "$?" > "$dir/exit" )
  echo "  exit=$(/bin/cat "$dir/exit")"
}

echo "SCENARIO 1: fresh machine, installer behaves"
XCODE_PRESENT=0 NIX_PRESENT=0 NIX_PROFILE=0 SDKMAN_PRESENT=0 \
  INSTALLER_CREATES_PROFILE=1 run_case fresh
D=$BASE/fresh
assert "xcode install attempted"  present "xcode-select --install" "$D/calls.log"
assert "nix installer run"        present "install.determinate.systems" "$D/calls.log"
assert "darwin-rebuild switch"    present "darwin-rebuild -- switch --flake" "$D/calls.log"
assert "switch targets #skippednote" present "#skippednote" "$D/calls.log"
assert "sdkman fetched"           present "get.sdkman.io" "$D/calls.log"
assert "no uv-tools step"         absent  "uv-tools" "$D/out.log"
assert "exit 0"                   present "^0$" "$D/exit"

echo "SCENARIO 2: fresh machine, installer leaves no profile script"
XCODE_PRESENT=0 NIX_PRESENT=0 NIX_PROFILE=0 SDKMAN_PRESENT=0 \
  INSTALLER_CREATES_PROFILE=0 run_case broken
D=$BASE/broken
assert "explains the failure" present "is missing" "$D/out.log"
assert "tells you what to do" present "new terminal" "$D/out.log"
assert "does not switch"      absent  "darwin-rebuild" "$D/calls.log"
assert "exit 1"               present "^1$" "$D/exit"

echo "SCENARIO 3: already configured"
XCODE_PRESENT=1 NIX_PRESENT=1 NIX_PROFILE=1 SDKMAN_PRESENT=1 run_case configured
D=$BASE/configured
assert "xcode skipped"       present "already installed" "$D/out.log"
assert "no reinstall of nix" absent  "install.determinate.systems" "$D/calls.log"
assert "sdkman skipped"      absent  "get.sdkman.io" "$D/calls.log"
assert "still switches"      present "darwin-rebuild -- switch" "$D/calls.log"
assert "exit 0"              present "^0$" "$D/exit"

echo "SCENARIO 5: host is skippedbook - sdkman must be skipped"
XCODE_PRESENT=1 NIX_PRESENT=1 NIX_PROFILE=1 SDKMAN_PRESENT=0 FAKE_HOST=skippedbook run_case book
D=$BASE/book
assert "switch targets #skippedbook" present "#skippedbook" "$D/calls.log"
assert "sdkman skipped"              present "does not use JVM"  "$D/out.log"
assert "sdkman not fetched"          absent  "get.sdkman.io"     "$D/calls.log"
assert "exit 0"                      present "^0$"               "$D/exit"

echo "SCENARIO 4: nix present, sdkman missing, no bash 4+ available"
XCODE_PRESENT=1 NIX_PRESENT=1 NIX_PROFILE=1 SDKMAN_PRESENT=0 run_case nobash
D=$BASE/nobash
assert "switch still ran" present "darwin-rebuild -- switch" "$D/calls.log"
assert "exit 0 regardless" present "^0$" "$D/exit"

echo ""
echo "════ $PASS passed, $FAIL failed ════"
[ "$FAIL" -eq 0 ]
