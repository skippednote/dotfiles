# atuin from upstream's prebuilt binary rather than nixpkgs.
#
# nixpkgs is stuck at 18.19.0 because atuin 18.21.0 requires rustc 1.98.0 and
# no nixpkgs revision has it yet - the locked input and master are both on
# 1.97.1, so building from source fails with:
#
#   atuin-server@18.21.0 requires rustc 1.98.0
#
# Staying on 18.19.0 is not an option either: 18.21 has already applied
# migration 20260818000000 to the local history database, and 18.19 refuses to
# open a database carrying a migration it does not know, so the whole shell
# history would have to be discarded.
#
# This installs the same artifact mise was downloading. To bump: change the
# version, then get the hash with
#
#   nix store prefetch-file https://github.com/atuinsh/atuin/releases/download/vX.Y.Z/atuin-aarch64-apple-darwin.tar.gz
#
# Revisit once nixpkgs carries rustc >= 1.98.0 and bumps atuin, at which point
# this file can be deleted in favour of pkgs.atuin.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "atuin";
  version = "18.21.0";

  src = fetchurl {
    url = "https://github.com/atuinsh/atuin/releases/download/v${finalAttrs.version}/atuin-aarch64-apple-darwin.tar.gz";
    hash = "sha256-x4rBWcicOO4LVutqEdnApzQN46A7mPu8zUT44tkebm4=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 */atuin $out/bin/atuin
    runHook postInstall
  '';

  meta = {
    description = "Shell history replacement, from upstream's prebuilt binary";
    homepage = "https://atuin.sh";
    license = lib.licenses.mit;
    mainProgram = "atuin";
    platforms = [ "aarch64-darwin" ];
  };
})
