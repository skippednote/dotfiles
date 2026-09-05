# Nightly pull-backup of the press production database and assets.
#
# ~/Code/personal/press/scripts/backup-press.sh has existed since June and is
# explicit that it must run here: "the box can't reach the laptop, so backups
# are pull-based from here." It was never wired up. ~/press-backups did not
# exist, nothing scheduled it, and it appears nowhere in 51,772 commands of
# shell history - so press-postgres has had no routine backup at all, while
# baheej on the same box has been dumping itself nightly since forever.
#
# 03:40, after the box's own 03:00 baheej backup so the two do not contend
# for it at once.
#
# PRESS_BOX points at the press-box alias in .ssh/config-skippednote rather
# than root@46.224.90.192 directly: the alias pins an on-disk key and
# disables the 1Password agent, which would otherwise prompt for approval on
# a machine nobody is sitting at.
{ ... }:

{
  launchd.user.agents."com.skippednote.press-backup".serviceConfig = {
    Label = "com.skippednote.press-backup";

    ProgramArguments = [
      "/bin/bash"
      "/Users/skippednote/Code/personal/press/scripts/backup-press.sh"
    ];

    StartCalendarInterval = [
      {
        Hour = 3;
        Minute = 40;
      }
    ];

    StandardOutPath = "/Users/skippednote/Library/Logs/press-backup.log";
    StandardErrorPath = "/Users/skippednote/Library/Logs/press-backup.log";

    EnvironmentVariables = {
      PRESS_BOX = "press-box";
      HOME = "/Users/skippednote";
      # gzip, ssh and the coreutils the script leans on. The Nix profile
      # first so it does not depend on whatever launchd inherits.
      PATH = "/etc/profiles/per-user/skippednote/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    };

    # A laptop is asleep at 03:40 more often than not; without this the run
    # is simply skipped rather than deferred to when it next wakes.
    RunAtLoad = false;
  };
}
