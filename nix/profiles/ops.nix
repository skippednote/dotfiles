# Self-hosting and operations tools: skippedbook only.
#
# Taken from what that machine already runs. Four of these match its current
# versions exactly, so adopting them changes nothing but the source:
#
#   age 1.3.2  fluxcd 2.9.4  gitleaks 8.30.1  restic 0.19.1
#
# tmux is newer in nixpkgs (3.7c against 3.6b) and ffmpeg matches at 9.0.1.
#
# `batt` is the only tool on that machine nixpkgs does not carry, so it stays
# a Homebrew formula - see nix/hosts/skippedbook.nix.
{ pkgs, user, ... }:

{
  home-manager.users.${user}.home.packages = with pkgs; [
    # Secrets: age is the backend sops uses there
    age

    # GitOps for the OrbStack k8s cluster
    fluxcd # the `flux` binary

    # Backups for ~/selfhost, driven by the selfhost-backup launchd agent
    restic

    # Secret scanning
    gitleaks

    # Terminal multiplexing on a machine that is mostly reached over SSH
    tmux

    # Media processing and socket plumbing for the selfhost stack
    ffmpeg
    socat
  ];
}
