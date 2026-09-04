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

    # Batch D2: the keepalive services, including the hermes gateway. Unlike
    # D1, this one really does restart things: the hermes PATHs differ from
    # the live plists, which is the point - it is what cuts them off mise.
    ../agents/skippedbook/services.nix
  ];

  networking.computerName = "skippedbook";
  networking.hostName = "skippedbook";
  networking.localHostName = "skippedbook";

  homebrew = {
    # batt is the only one of this machine's 22 tools that nixpkgs does not
    # carry; everything else moved to nix/profiles/{common,ops}.nix.
    brews = [ "batt" ];

    casks = [
      # Installed and signed in, with the ssh agent enabled. Commit signing
      # is still off and the ssh config still uses its own IdentityFile,
      # because the agent prompts for approval on this machine's display
      # and this machine is driven over SSH. See
      # home/.config/git/host-skippedbook.conf.
      "1password"
      "lm-studio"
      "orbstack" # the k8s cluster and every container depend on this
      "tailscale-app"
    ];

    # Nothing from the App Store on this machine.
    masApps = { };
  };
}
