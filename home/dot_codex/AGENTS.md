@/Users/skippednote/.codex/RTK.md
@/Users/skippednote/.config/ai/working-preferences.md

## Codex specifics

- Long-running / monitoring jobs: self-pace on a fixed interval (heartbeat), keep each pass read-only, and report a one-line delta vs the last checkpoint. Flag anomalies; otherwise say "no changes applied".
- When done, hand back the concrete artifact — a link, PR, diff, or curl. Ship reports as a deployable HTML / Confluence / Spin doc when asked, and offer to open or deploy it.
- Pull context from the source (Jira/Confluence, Slack history, prior sessions) instead of asking me for what you can fetch yourself.
- Roll out risky or infra changes in reversible stages: observe/log → soft action → enforce.
