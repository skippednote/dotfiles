# Self-hosting and operations tools: skippedbook only.
#
# Each of these was traced to real use in ~/selfhost rather than carried
# across on inventory. Four match that machine's pre-migration versions
# exactly, so adopting them changed the source and nothing else:
#
#   age 1.3.2  fluxcd 2.9.4  gitleaks 8.30.1  restic 0.19.1
#
# `batt` is the only tool on that machine nixpkgs does not carry, so it stays
# a Homebrew formula - see nix/hosts/skippedbook.nix.
{ pkgs, user, ... }:

{
  home-manager.users.${user}.home.packages = with pkgs; [
    # The SOPS backend. k8s secrets are committed encrypted
    # (k8s/secrets/*.sops.yaml) and flux decrypts them during reconciliation,
    # so this is load-bearing rather than convenient.
    age

    # The `flux` CLI for the six flux-system controllers in the cluster.
    fluxcd

    # Backups, driven by the selfhost-backup agent at 03:30 and verified by
    # selfhost-restore-check at 04:15.
    restic

    # Runs from ~/selfhost/hooks/pre-commit and from the selfhost-checks CI
    # workflow. With age-encrypted secrets in that repo, this is the guard
    # against committing an unencrypted one.
    gitleaks

    # Jellyfin transcoding (app-configs/jellyfin/config/encoding.xml) and
    # Home Assistant camera streams.
    ffmpeg

    # Proxies an RTSP camera stream for Home Assistant. Note its only
    # consumer, dev.skippednote.cpplus-rtsp-proxy, is currently disabled - so
    # this may be dormant. Kept because the agent is disabled rather than
    # deleted, which reads as temporary.
    socat
  ];
}
