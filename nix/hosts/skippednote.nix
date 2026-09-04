# skippednote: the personal development laptop.
{ pkgs, ... }:

{
  networking.computerName = "skippednote";
  networking.hostName = "skippednote";
  networking.localHostName = "skippednote";

  # Replaces the font-fira-code-nerd-font cask. Not shared: a terminal font
  # earns nothing on a machine reached over SSH.
  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  system.defaults = {
    # Native tiling off; Rectangle handles window management.
    WindowManager = {
      GloballyEnabled = false;
      EnableTiledWindowMargins = false;
      EnableTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      EnableTopTilingByEdgeDrag = false;
      HideDesktop = true;
    };

    CustomUserPreferences = {
      "com.knollsoft.Rectangle" = {
        launchOnLogin = true;
        hideMenubarIcon = true;
        alternateDefaultShortcuts = true;
        allowAnyShortcut = true;
        subsequentExecutionMode = 1;
      };
      # Cmd+Space, replacing Spotlight.
      "com.raycast.macos".raycastGlobalHotkey = "Command-49";
    };
  };

  homebrew = {
    brews = [
      "mas" # for `make mas-update`
      "zsh-autosuggestions" # .zshrc sources this from /opt/homebrew/share
    ];

    casks = [
      "1password"
      "chatgpt"
      "claude"
      "cleanshot"
      "cmux"
      "google-chrome"
      "granola"
      "grok-bot"
      "insta360-link-controller"
      "logi-options+"
      "microsoft-teams"
      "notion-calendar"
      "orbstack"
      "raycast"
      "rectangle"
      "slack"
      "tailscale-app"
      "whatsapp"
      "wispr-flow"
      "zed"
      "zoom"
    ];

    # Installed by hand from the App Store; mas enumerates through Spotlight
    # and only agrees with reality while that index is healthy.
    masApps = {
      "Developer" = 640199958;
      "WireGuard" = 1451685025;
    };
  };
}
