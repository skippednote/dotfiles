# Work MacBook. Scaffold only - this machine does not exist yet.
#
# Intended to diverge from personal.nix in its cask and masApps lists rather
# than in system settings, so keep shared configuration in nix/modules/.
{ hostname, ... }:

{
  networking.computerName = hostname;
  networking.hostName = hostname;
  networking.localHostName = hostname;
}
