# skippedbook: self-hosting box.
#
# Runs an OrbStack Kubernetes cluster (flux GitOps, a VictoriaMetrics and
# Grafana monitoring stack, ~27 services in the selfhost namespace) plus 23
# launchd agents driving scripts in ~/selfhost. LM Studio runs here too.
#
# Reached over SSH almost exclusively, so it gets no fonts, no Dock or
# Finder tuning beyond the shared defaults, and none of the Rectangle or
# Raycast preferences - neither app is installed.
{ ... }:

{
  # Phase D wires this in. It is deliberately left out of the first switch so
  # that switch changes tools and dotfiles only, and the 23 hand-placed plists
  # keep running untouched while the rest is verified. Enabling it unloads and
  # reloads every agent at once, which is not something to combine with a
  # machine's first ever activation.
  #
  # imports = [ ../agents/skippedbook.nix ];

  networking.computerName = "skippedbook";
  networking.hostName = "skippedbook";
  networking.localHostName = "skippedbook";

  homebrew = {
    # batt is the only one of this machine's 22 tools that nixpkgs does not
    # carry; everything else moved to nix/profiles/{common,ops}.nix.
    brews = [ "batt" ];

    casks = [
      # Installing the app does not by itself enable commit signing or the
      # ssh agent here: both need signing in and turning the agent on in
      # Settings > Developer. Until that is done, host-skippedbook.conf
      # keeps signing off and the ssh config keeps its own IdentityFile -
      # pointing either at an absent op socket is what broke outbound ssh
      # on this machine once already.
      "1password"
      "lm-studio"
      "orbstack" # the k8s cluster and every container depend on this
      "tailscale-app"
    ];

    # Nothing from the App Store on this machine.
    masApps = { };
  };
}
