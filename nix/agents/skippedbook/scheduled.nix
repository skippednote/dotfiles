# skippedbook: scheduled launchd jobs.
#
# The 18 timer-driven and run-at-load agents, transcribed from the plists
# that were hand-placed in ~/Library/LaunchAgents. Verified equivalent
# before adoption: 14 were byte-identical and the four daily ones differed
# only by nix-darwin defaulting unset StartCalendarInterval fields to null,
# which are filtered when the plist is written.
#
# These are cut over before the long-running services in ./services.nix,
# because a misfiring timer shows up in its own log on the next tick,
# whereas a broken keepalive service is down until noticed.
#
# nix-darwin owns the schedule and the command. The scripts live in
# ~/selfhost, its own git repo, and they source ~/selfhost/.env - no secret
# from that machine belongs here.
{ ... }:

{
  launchd.user.agents = {

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
  };
}
