# Acquia CLI from upstream's released phar. Not in nixpkgs at all.
#
# acli ships only as a PHP archive attached to a GitHub release; there is no
# package to track. The version and hash here are deliberately the same ones
# pinned in the PADI backend repo's .aws/buildspec-deploy.yml, so the acli that
# pulls a database locally is byte-identical to the one CI deploys with. That
# repo refuses to run a mismatched checksum, and this should not diverge from it
# silently.
#
# To bump: change the version here AND in that buildspec together, then get the
# hash with
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
  version = "2.61.3";

  src = fetchurl {
    url = "https://github.com/acquia/cli/releases/download/${finalAttrs.version}/acli.phar";
    hash = "sha256-MVgTJeduyucVoSc+5EJ9RhC53LZUXNa6rdvwTDRWBVA=";
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
