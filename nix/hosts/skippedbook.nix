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
  imports = [
    # Batch D1: the 18 timer-driven jobs. A misfiring timer surfaces in its
    # own log on the next tick.
    ../agents/skippedbook/scheduled.nix

    # Batch D2: the keepalive services, including the hermes gateway. Enable
    # this only once D1 has been observed working - a mistake here is an
    # outage rather than a missed tick.
    # ../agents/skippedbook/services.nix
  ];

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
