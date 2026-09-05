# Daily drift check for this repo on skippedbook.
#
# Unlike the agents in ./scheduled.nix, this one is not transcribed from a
# hand-placed plist - it is new, and it exists because every regression
# during the migration to Nix came from the repo and a machine disagreeing
# silently. skippedbook is reached over SSH, so it is the machine where that
# silence lasts longest.
#
# It runs at 09:05, five minutes after ~/selfhost's own drift check at 09:00,
# so the two do not compete for the same Telegram topic in the same second.
{ ... }:

{
  launchd.user.agents."com.skippednote.dotfiles-drift".serviceConfig = {
    Label = "com.skippednote.dotfiles-drift";

    ProgramArguments = [
      "/bin/bash"
      "/Users/skippednote/Code/personal/dotfiles/scripts/drift-notify.sh"
    ];

    StartCalendarInterval = [
      {
        Hour = 9;
        Minute = 5;
      }
    ];

    StandardOutPath = "/Users/skippednote/selfhost/logs/dotfiles-drift.log";
    StandardErrorPath = "/Users/skippednote/selfhost/logs/dotfiles-drift.log";

    # nix is needed for the generation and atuin-pin checks; without it those
    # two are skipped and the check silently becomes weaker.
    EnvironmentVariables = {
      PATH = "/etc/profiles/per-user/skippednote/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      HOME = "/Users/skippednote";
    };
  };
}
