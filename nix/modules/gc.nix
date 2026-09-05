# Store garbage collection.
#
# nix-darwin's `nix.gc` options are unavailable here: Determinate owns the
# daemon and nix.conf, so `nix.enable = false`, which disables that whole
# module. Nothing else collects, and the store had grown to 12 GB with 1,970
# dead paths and 16 system generations before this existed.
#
# A system-level launchd daemon rather than a user agent, because deleting
# generations needs root.
{ pkgs, ... }:

{
  launchd.daemons.nix-gc = {
    serviceConfig = {
      Label = "org.nixos.gc";

      # Weekly, Sunday 04:00 - after skippedbook's 03:30 backup and its
      # 04:15 restore check would be a collision, so this sits between them
      # only on the day they all coincide; GC is interruptible and holds no
      # lock those need.
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 4;
          Minute = 0;
        }
      ];

      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };

    # Two steps, deliberately in this order. Deleting old generations first
    # is what makes their closures collectable; running gc alone would free
    # almost nothing while 16 generations still root everything.
    #
    # 30 days keeps a month of rollback, which is far more than the "did the
    # last switch break something" window generations actually get used for.
    script = ''
      set -eu
      export PATH=${pkgs.nix}/bin:$PATH
      echo "=== $(date) ==="
      nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
      nix store gc --verbose 2>&1 | tail -5
      echo "store now: $(du -sh /nix/store 2>/dev/null | cut -f1)"
    '';
  };
}
