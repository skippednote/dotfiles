#!/usr/bin/env bash
# Install the global uv-managed CLI tools that nixpkgs cannot provide.
#
# Everything else that used to be installed here now comes from Nix; see
# nix/modules/packages.nix. What remains is PyPI-only:
#
#   llvd, semble, spec-kitty-cli        not in nixpkgs at all
#   grip, hypothesis, radon, weasyprint only exist as python3Packages.*, and
#                                       keeping them here avoids standing up a
#                                       python env for four CLIs
#
# uv itself comes from Nix. Tools that moved to Nix are not uninstalled
# automatically - clear the stale shims once with:
#
#   uv tool uninstall ansible ansible-core aws-sam-cli basedpyright \
#     markitdown poetry ruff yt-dlp
#
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not found - run 'make switch' first." >&2
  exit 1
fi

uv tool install grip
uv tool install hypothesis
uv tool install llvd
uv tool install radon
uv tool install semble
uv tool install spec-kitty-cli
uv tool install weasyprint
uv tool upgrade --all

echo "uv tools installed and upgraded."
