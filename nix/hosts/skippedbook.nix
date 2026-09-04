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
  imports = [ ../agents/skippedbook.nix ];

  networking.computerName = "skippedbook";
  networking.hostName = "skippedbook";
  networking.localHostName = "skippedbook";

  homebrew = {
    # batt is the only one of this machine's 22 tools that nixpkgs does not
    # carry; everything else moved to nix/profiles/{common,ops}.nix.
    brews = [ "batt" ];

    casks = [
      "lm-studio"
      "orbstack" # the k8s cluster and every container depend on this
      "tailscale-app"
    ];

    # Nothing from the App Store on this machine.
    masApps = { };
  };
}
