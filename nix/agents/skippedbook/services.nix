# skippedbook: long-running launchd services.
#
# Cut over after ./scheduled.nix. These are keepalive, so a mistake here is
# an outage rather than a missed tick - the hermes gateway most of all.
#
# Both hermes agents had mise baked into their PATH: ten absolute install
# paths pinned to exact versions in the gateway, and mise/shims in the
# dashboard. Those are replaced with the Nix profiles here, which is what
# makes it safe to empty mise's global tools on this machine afterwards.
{ pkgs, lib, ... }:

let
  # Same reasoning as ./scheduled.nix: these were transcribed from plists
  # that relied on mise shims, and those shims now dangle. recursiveUpdate
  # means an agent setting its own PATH - the two hermes ones do - keeps it.
  agentPath =
    "/etc/profiles/per-user/skippednote/bin:"
    + "/run/current-system/sw/bin:"
    + "/nix/var/nix/profiles/default/bin:"
    + "/Applications/OrbStack.app/Contents/MacOS/xbin:"
    + "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";

  withPath =
    _: agent:
    lib.recursiveUpdate {
      serviceConfig.EnvironmentVariables = {
        PATH = agentPath;
        HOME = "/Users/skippednote";
      };
    } agent;
in

{
  launchd.user.agents = lib.mapAttrs withPath {
    # ── Hermes AI
    "ai.hermes.gateway".serviceConfig = {
      EnvironmentVariables = {
        HERMES_HOME = "/Users/skippednote/.hermes";
        VIRTUAL_ENV = "/Users/skippednote/.hermes/hermes-agent/venv";
      };
      KeepAlive = true;
      Label = "ai.hermes.gateway";
      ProgramArguments = [
        "/Users/skippednote/.hermes/scripts/run_gateway_with_vaultwarden_env.sh"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/.hermes/logs/gateway.error.log";
      StandardOutPath = "/Users/skippednote/.hermes/logs/gateway.log";
      ThrottleInterval = 30;
      WorkingDirectory = "/Users/skippednote/.hermes/hermes-agent";
      EnvironmentVariables.PATH =
        # node 26 by store path: the gateway runs 26.1.0 and the user
        # profile carries the 24 LTS, so resolving it from the profile would
        # be a two-major downgrade. Adding a second nodejs to the profile
        # would collide, so it is pinned to this service only.
        "${pkgs.nodejs_26}/bin:"
        + "/Users/skippednote/.hermes/hermes-agent/venv/bin:"
        + "/Users/skippednote/.hermes/hermes-agent/node_modules/.bin:"
        + "/etc/profiles/per-user/skippednote/bin:"
        + "/run/current-system/sw/bin:"
        + "/nix/var/nix/profiles/default/bin:"
        + "/Users/skippednote/.local/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/pkg/env/active/bin:/opt/pmk/env/global/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/skippednote/.orbstack/bin:/Users/skippednote/.lmstudio/bin";
    };

    "ai.hermes.dashboard".serviceConfig = {
      EnvironmentVariables = {
        HERMES_HOME = "/Users/skippednote/.hermes";
      };
      KeepAlive = true;
      Label = "ai.hermes.dashboard";
      ProgramArguments = [
        "/Users/skippednote/.hermes/scripts/run_hermes_dashboard.sh"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/.hermes/logs/hermes-dashboard.error.log";
      StandardOutPath = "/Users/skippednote/.hermes/logs/hermes-dashboard.log";
      WorkingDirectory = "/Users/skippednote/.hermes/hermes-agent";
      EnvironmentVariables.PATH =
        "/Users/skippednote/.local/bin:"
        + "/etc/profiles/per-user/skippednote/bin:"
        + "/run/current-system/sw/bin:"
        + "/nix/var/nix/profiles/default/bin:"
        + "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    };

    # ── selfhost daemons
    "com.skippednote.health-events".serviceConfig = {
      EnvironmentVariables = {
        HOME = "/Users/skippednote";
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
      KeepAlive = true;
      Label = "com.skippednote.health-events";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "exec /Users/skippednote/selfhost/health-events/healthd -listen 127.0.0.1:8771 -out /Users/skippednote/selfhost/health-events/health.json -history /Users/skippednote/selfhost/health-events/health-history.jsonl -events /Users/skippednote/selfhost/health-events/health-events.db -archive /Users/skippednote/selfhost/health-events/health-archive.db"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/health-events.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/health-events.log";
    };
    "com.skippednote.triggers".serviceConfig = {
      KeepAlive = true;
      Label = "com.skippednote.triggers";
      ProgramArguments = [
        "/Users/skippednote/selfhost/triggers/triggers"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/triggers.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/triggers.log";
    };
    "com.skippednote.zerodha-reauth".serviceConfig = {
      EnvironmentVariables = {
        HOME = "/Users/skippednote";
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
      KeepAlive = true;
      Label = "com.skippednote.zerodha-reauth";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "set -a; source /Users/skippednote/selfhost/.env; set +a; exec /Users/skippednote/selfhost/zerodha-reauth/zerodha-reauth"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/Users/skippednote/selfhost/logs/zerodha-reauth.err";
      StandardOutPath = "/Users/skippednote/selfhost/logs/zerodha-reauth.log";
    };

    # Replaces homebrew.mxcl.atuin, which went away with the formula. Same
    # daemon from the Nix package; logs move out of /opt/homebrew/var/log.
    "sh.atuin.daemon".serviceConfig = {
      Label = "sh.atuin.daemon";
      ProgramArguments = [
        "${pkgs.callPackage ../../packages/atuin.nix { }}/bin/atuin"
        "daemon"
        "start"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Users/skippednote/Library/Logs/atuin.log";
      StandardErrorPath = "/Users/skippednote/Library/Logs/atuin.log";
    };
  };
}
