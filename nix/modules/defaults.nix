# macOS preferences shared by every host, ported from the old defaults.sh.
#
# Settings that depend on an app being installed live in the host files
# instead: Rectangle and Raycast are on skippednote only, and writing their
# preference domains on a machine without them is pointless.
#
# Everything nix-darwin models as a real option is set that way. The rest
# goes through CustomUserPreferences, which writes arbitrary domain/key
# pairs - so none of this needs a shell script, and all of it is idempotent.
{ ... }:

{
  # Replaces both of the old mechanisms: the hidutil call in defaults.sh and
  # the com.skippednote.capslock-to-control LaunchAgent. nix-darwin emits the
  # same mapping, 0x700000039 -> 0x7000000E0.
  # enableKeyMapping is required, or the remap below is silently a no-op.
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults = {
    dock = {
      autohide = true;
      tilesize = 16;
      orientation = "left";
      show-recents = false;
      minimize-to-application = true;
      mru-spaces = false; # do not auto-rearrange spaces

      # Plain strings are coerced to { app = ...; } and rendered as the same
      # tile-data/_CFURLString plist entries the old array literal spelled out.
      persistent-apps = [
        "/System/Applications/Mail.app"
        "/Applications/Google Chrome.app"
      ];

      # Bottom left opens Quick Note. The other three corners are disabled by
      # setting 0, which this option's type (ints.positive) rejects, so they
      # are set through CustomUserPreferences below.
      wvous-bl-corner = 14;
    };

    finder = {
      ShowPathbar = false;
      ShowStatusBar = false;
      FXPreferredViewStyle = "clmv"; # column view
      NewWindowTarget = "Home";
      FXRemoveOldTrashItems = true; # empty trash after 30 days
      ShowHardDrivesOnDesktop = false;
    };

    # The com.apple.menuextra.clock domain.
    menuExtraClock = {
      ShowDayOfWeek = true;
      ShowAMPM = true;
      ShowDate = 0; # when space allows
      ShowSeconds = false;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";

      # Text corrections off, except period substitution.
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = true;

      # defaults.sh wrote this with -currentHost, which nix-darwin cannot
      # target; this writes the plain domain instead. Needs a real click to
      # confirm rather than a plist diff.
      "com.apple.mouse.tapBehavior" = 1;
    };

    trackpad.Clicking = true; # tap to click

    # Keys with no nix-darwin option, written by domain.
    CustomUserPreferences = {
      "com.apple.finder".FXPreferredGroupBy = "Kind";

      # 0 disables a hot corner, which the typed options reject.
      "com.apple.dock" = {
        wvous-tl-corner = 0;
        wvous-tr-corner = 0;
        wvous-br-corner = 0;
      };

      # `with` is a Nix keyword, hence the quoting.
      NSGlobalDomain.NSUserDictionaryReplacementItems = [
        {
          on = 1;
          replace = "@lin";
          "with" = "https://www.linkedin.com/in/skippednote";
        }
        {
          on = 1;
          replace = "fe";
          "with" = "frontend";
        }
        {
          on = 1;
          replace = "@p";
          "with" = "mail@skippednote.dev";
        }
        {
          on = 1;
          replace = "upi";
          "with" = "skippednote@okhdfcbank";
        }
        {
          on = 1;
          replace = "@c";
          "with" = "bassam@axelerant.com";
        }
        {
          on = 1;
          replace = "@z";
          "with" = "https://axelerant.zoom.us/my/skippednote";
        }
        {
          on = 1;
          replace = "ahd";
          "with" = "Alhamdullialh";
        }
        {
          on = 1;
          replace = "@@";
          "with" = "skippednote@gmail.com";
        }
        {
          on = 1;
          replace = "asa";
          "with" = "Assalamu Alaikum";
        }
        {
          on = 1;
          replace = "ws";
          "with" = "Wa-Alaikum-Salaam";
        }
        {
          on = 1;
          replace = "isa";
          "with" = "In Sha Allah";
        }
      ];
    };
  };
}
