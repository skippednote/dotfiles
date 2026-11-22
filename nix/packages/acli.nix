# Acquia CLI from upstream's released phar. Not in nixpkgs at all.
#
# acli ships only as a PHP archive attached to a GitHub release; there is no
# package to track. This follows upstream's latest release and is not tied to
# CI: PADI deploys with the acli baked into the padi-ci image, pinned
# separately in that repo's images/lib/versions.env (2.61.3 when this was
# written).
#
# To bump: change the version, then get the hash with
#
#   nix store prefetch-file https://github.com/acquia/cli/releases/download/X.Y.Z/acli.phar
#
# The phar needs a PHP interpreter at runtime, so it is wrapped rather than
# installed bare - nothing else here should have to care that it is PHP.
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  php,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "acli";
  version = "4.4.0";

  src = fetchurl {
    url = "https://github.com/acquia/cli/releases/download/${finalAttrs.version}/acli.phar";
    hash = "sha256-hq9NWjG3vYJQrhoCjI2ZcpoiGdQ0EC2bHfxVLs5dT2M=";
  };

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/libexec/acli.phar
    makeWrapper ${lib.getExe php} $out/bin/acli --add-flags $out/libexec/acli.phar
    runHook postInstall
  '';

  meta = {
    description = "Acquia CLI, from upstream's released phar";
    homepage = "https://github.com/acquia/cli";
    license = lib.licenses.gpl2Only;
    mainProgram = "acli";
    platforms = lib.platforms.unix;
  };
})
