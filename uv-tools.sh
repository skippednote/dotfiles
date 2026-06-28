#!/usr/bin/env bash
# Install global uv-managed CLI tools.
#
# These are installed via `uv tool` (uv itself comes from mise), so mise does
# not track them. Re-run on a fresh machine after `mise install` provides uv.
# Regenerate this list from the current machine with: uv tool list
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not found — run 'mise install' first." >&2
  exit 1
fi

uv tool install ansible
uv tool install ansible-core --with boto3 --with botocore
uv tool install aws-sam-cli
uv tool install grip
uv tool install llvd
uv tool install 'markitdown[all]'
uv tool install poetry
uv tool install radon
uv tool install ruff
uv tool install spec-kitty-cli
uv tool install weasyprint
uv tool install yt-dlp

echo "uv tools installed."
