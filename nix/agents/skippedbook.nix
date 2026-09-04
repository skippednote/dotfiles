# launchd agents for skippedbook.
#
# Transcribed mechanically from the 23 plists that were hand-placed in
# ~/Library/LaunchAgents, so behaviour is unchanged - the generated plists
# were diffed against the originals before this was applied.
#
# What this file owns and what it does not: nix-darwin declares the schedule
# and the command. The scripts themselves live in ~/selfhost, which is its
# own git repo, and they source ~/selfhost/.env. No secret from that machine
# belongs here, and the EnvironmentVariables blocks below were checked - they
# carry only PATH, HOME and HERMES_HOME.
#
# Six cruft files were dropped rather than transcribed: three
# .before-vaultwarden-cutover snapshots of the gateway plist, two .bak
# copies, and one .disabled.
#
# WARNING, and a blocker for the mise cutover on this machine: the two
# hermes agents bake absolute mise install paths into their PATH -
# ai.hermes.gateway has ten of them, pinned to exact versions
# (node/26.1.0/bin, go/1.26.3/bin, gh_2.92.0_macOS_arm64/bin,
# ripgrep-15.1.0-aarch64-apple-darwin, ...), and ai.hermes.dashboard uses
# mise/shims. Emptying mise's global [tools] here and running `mise prune`
# would delete those directories and silently strip node, go, gh, awscli,
# cloudflared, ripgrep, tmux and claude from the gateway's environment.
# Rewrite these PATHs to the Nix profiles before that step, not after.
#
# homebrew.mxcl.atuin is not here either. It was a Homebrew service, and the
# formula is gone; the atuin daemon is declared at the bottom against the
# Nix package instead.
{ pkgs, ... }:

{
  launchd.user.agents = {

    # ── Hermes AI services
    "ai.hermes.gateway".serviceConfig = {
      EnvironmentVariables = {
        HERMES_HOME = "/Users/skippednote/.hermes";
        PATH = "/Users/skippednote/.hermes/hermes-agent/venv/bin:/Users/skippednote/.hermes/hermes-agent/node_modules/.bin:/Users/skippednote/.local/share/mise/installs/node/26.1.0/bin:/Users/skippednote/.local/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/pkg/env/active/bin:/opt/pmk/env/global/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/skippednote/.local/share/mise/installs/claude/latest:/Users/skippednote/.local/share/mise/installs/github-zeroclaw-labs-zeroclaw/latest:/Users/skippednote/.local/share/mise/installs/go/1.26.3/bin:/Users/skippednote/.local/share/mise/installs/node/latest/bin:/Users/skippednote/.local/share/mise/installs/awscli/latest/.mise-bins:/Users/skippednote/.local/share/mise/installs/gh/latest/gh_2.92.0_macOS_arm64/bin:/Users/skippednote/.local/share/mise/installs/cloudflared/latest:/Users/skippednote/.local/share/mise/installs/ripgrep/latest/ripgrep-15.1.0-aarch64-apple-darwin:/Users/skippednote/.local/share/mise/installs/tmux/latest:/Users/skippednote/.orbstack/bin:/Users/skippednote/.lmstudio/bin";
        VIRTUAL_ENV = "/Users/skippednote/.hermes/hermes-agent/venv";
      };
      KeepAlive = true;
      Label = "ai.hermes.gateway";
      ProgramArguments = [
        "/Users/skippednote/.hermes/scripts/run_gateway_with_vaultwarden_env.sh"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/.hermes/logs/gateway.error.log";
      StandardOutPath = "/Users/skippednote/.hermes/logs/gateway.log";
      ThrottleInterval = 30;
      WorkingDirectory = "/Users/skippednote/.hermes/hermes-agent";
    };
    "ai.hermes.dashboard".serviceConfig = {
      EnvironmentVariables = {
        HERMES_HOME = "/Users/skippednote/.hermes";
        PATH = "/Users/skippednote/.local/bin:/Users/skippednote/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      KeepAlive = true;
      Label = "ai.hermes.dashboard";
      ProgramArguments = [
        "/Users/skippednote/.hermes/scripts/run_hermes_dashboard.sh"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/.hermes/logs/hermes-dashboard.error.log";
      StandardOutPath = "/Users/skippednote/.hermes/logs/hermes-dashboard.log";
      WorkingDirectory = "/Users/skippednote/.hermes/hermes-agent";
    };

    # ── Long-running selfhost services
    "com.skippednote.health-events".serviceConfig = {
      EnvironmentVariables = {
        HOME = "/Users/skippednote";
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
      KeepAlive = true;
      Label = "com.skippednote.health-events";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "exec /Users/skippednote/selfhost/health-events/healthd -listen 127.0.0.1:8771 -out /Users/skippednote/selfhost/health-events/health.json -history /Users/skippednote/selfhost/health-events/health-history.jsonl -events /Users/skippednote/selfhost/health-events/health-events.db -archive /Users/skippednote/selfhost/health-events/health-archive.db"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/health-events.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/health-events.log";
    };
    "com.skippednote.triggers".serviceConfig = {
      KeepAlive = true;
      Label = "com.skippednote.triggers";
      ProgramArguments = [
        "/Users/skippednote/selfhost/triggers/triggers"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/triggers.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/triggers.log";
    };
    "com.skippednote.zerodha-reauth".serviceConfig = {
      EnvironmentVariables = {
        HOME = "/Users/skippednote";
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
      KeepAlive = true;
      Label = "com.skippednote.zerodha-reauth";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "set -a; source /Users/skippednote/selfhost/.env; set +a; exec /Users/skippednote/selfhost/zerodha-reauth/zerodha-reauth"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/zerodha-reauth.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/zerodha-reauth.log";
    };

    # ── Frequent pollers (60s)
    "com.skippednote.battery".serviceConfig = {
      Label = "com.skippednote.battery";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/battery-export.sh"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/battery.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/battery.log";
      StartInterval = 60;
    };
    "com.skippednote.email".serviceConfig = {
      Label = "com.skippednote.email";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "export MAIL_U=\"$(grep -E '^EXP_EMAIL_USER=' /Users/skippednote/selfhost/.env | cut -d= -f2-)\"; export MAIL_P=\"$(grep -E '^EXP_EMAIL_PASS=' /Users/skippednote/selfhost/.env | cut -d= -f2-)\"; EXP_EMAIL_USER=\"$MAIL_U\" EXP_EMAIL_PASS=\"$MAIL_P\" exec /Users/skippednote/selfhost/email-importer/email-importer -out /Users/skippednote/selfhost/email-importer/emails.json"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/email.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/email.log";
      StartInterval = 60;
    };
    "com.skippednote.expenses".serviceConfig = {
      Label = "com.skippednote.expenses";
      ProgramArguments = [
        "/Users/skippednote/selfhost/expenses/launcher"
        "-out"
        "/Users/skippednote/selfhost/expenses/expenses.json"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/expenses.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/expenses.log";
      StartInterval = 60;
    };

    # ── Five-minute jobs
    "com.skippednote.container-watchdog".serviceConfig = {
      Label = "com.skippednote.container-watchdog";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/container-watchdog.sh"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-container-watchdog.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-container-watchdog.out";
      StartInterval = 300;
    };
    "com.skippednote.jellyseerr-cleanup".serviceConfig = {
      Label = "com.skippednote.jellyseerr-cleanup";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/jellyseerr-cleanup.sh"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-jellyseerr.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-jellyseerr.out";
      StartInterval = 300;
    };
    "com.skippednote.job-health".serviceConfig = {
      Label = "com.skippednote.job-health";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/job-health.sh"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-job-health.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-job-health.out";
      StartInterval = 300;
    };
    "com.skippednote.ledger".serviceConfig = {
      Label = "com.skippednote.ledger";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "set -a; source /Users/skippednote/selfhost/.env; set +a; cd /Users/skippednote/selfhost/beancount && python3 reconcile.py --out hdfc-pending.beancount --cutoff 2026-05-16 && mkdir -p /Users/skippednote/selfhost/beancount-stats && python3 ledger_stats.py main.beancount --out /Users/skippednote/selfhost/beancount-stats/ledger-stats.json && OUT=/Users/skippednote/selfhost/beancount-stats/habits.json python3 beaver_aggregate.py"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/ledger.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/ledger.log";
      StartInterval = 300;
    };
    "com.skippednote.stalled-cleanup".serviceConfig = {
      Label = "com.skippednote.stalled-cleanup";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/stalled-cleanup.sh"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-stalled.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-stalled.out";
      StartInterval = 300;
    };

    # ── Quarter-hour jobs
    "com.skippednote.disk-alert".serviceConfig = {
      Label = "com.skippednote.disk-alert";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/disk-alert.sh"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-disk.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-disk.out";
      StartInterval = 900;
    };
    "com.skippednote.media-health".serviceConfig = {
      Label = "com.skippednote.media-health";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/media-health.sh"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-media-health.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-media-health.out";
      StartInterval = 900;
    };
    "com.skippednote.portfolio".serviceConfig = {
      Label = "com.skippednote.portfolio";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "set -a; source /Users/skippednote/selfhost/.env; set +a; /Users/skippednote/selfhost/portfolio/portfolio -out /Users/skippednote/selfhost/portfolio/portfolio.json"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/portfolio.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/portfolio.log";
      StartInterval = 900;
    };

    # ── Six-hourly jobs
    "com.skippednote.kpdcl".serviceConfig = {
      Label = "com.skippednote.kpdcl";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/kpdcl-export.sh"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-kpdcl.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-kpdcl.out";
      StartInterval = 21600;
    };
    "com.skippednote.premiere-guard".serviceConfig = {
      Label = "com.skippednote.premiere-guard";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/premiere-guard.sh"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-premiere-guard.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-premiere-guard.out";
      StartInterval = 21600;
    };

    # ── Daily jobs
    "com.skippednote.selfhost-backup".serviceConfig = {
      Label = "com.skippednote.selfhost-backup";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/backup.sh"
      ];
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-backup.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-backup.out";
      StartCalendarInterval = {
        Hour = 3;
        Minute = 30;
      };
    };
    "com.skippednote.orphan-sweep".serviceConfig = {
      Label = "com.skippednote.orphan-sweep";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/downloads-orphan-sweep.sh"
        "--apply"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-orphan-sweep.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-orphan-sweep.out";
      StartCalendarInterval = {
        Hour = 4;
        Minute = 10;
      };
    };
    "com.skippednote.selfhost-restore-check".serviceConfig = {
      Label = "com.skippednote.selfhost-restore-check";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/restore-check-weekly.sh"
      ];
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-restore-check.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-restore-check.out";
      StartCalendarInterval = {
        Hour = 4;
        Minute = 15;
        Weekday = 0;
      };
    };
    "com.skippednote.drift-check".serviceConfig = {
      Label = "com.skippednote.drift-check";
      ProgramArguments = [
        "/bin/bash"
        "/Users/skippednote/selfhost/scripts/drift-check.sh"
      ];
      RunAtLoad = false;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-drift.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-drift.out";
      StartCalendarInterval = {
        Hour = 9;
        Minute = 0;
      };
    };

    # ── Run at load
    "com.skippednote.orbstack-autostart".serviceConfig = {
      Label = "com.skippednote.orbstack-autostart";
      ProgramArguments = [
        "/usr/bin/open"
        "-g"
        "-a"
        "/Applications/OrbStack.app"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/launchd-orbstack.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/launchd-orbstack.out";
    };

    # Replaces the homebrew.mxcl.atuin service, which disappeared with the
    # formula. Same daemon, pointed at the Nix binary; logs move out of
    # /opt/homebrew/var/log.
    "sh.atuin.daemon".serviceConfig = {
      Label = "sh.atuin.daemon";
      ProgramArguments = [
        "${pkgs.callPackage ../packages/atuin.nix { }}/bin/atuin"
        "daemon"
        "start"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Users/skippednote/Library/Logs/atuin.log";
      StandardErrorPath = "/Users/skippednote/Library/Logs/atuin.log";
    };
  };
}
