# gameping from source. My own tool, not in nixpkgs, and the repo ships no
# flake: building the tagged release here keeps it on the same path as
# disktree rather than adding a flake input for one binary.
#
# Every crate is on crates.io (no git sources in Cargo.lock), so cargoHash is
# enough and no lock file needs copying into this repo.
#
# To bump: change the version, then
#
#   nix flake prefetch github:skippednote/gameping/vX.Y.Z    # "hash" -> src.hash
#
# and set cargoHash to "" - the build failure prints the real value.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gameping";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "skippednote";
    repo = "gameping";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tDjqnMTZw4VybUxS/boV7JOwPKWc+7omyCd6XUMjHq0=";
  };

  cargoHash = "sha256-z17NBZn5vt8cd8hnlZNX/iF+kwwnEunzv8RHA/xncEo=";

  meta = {
    description = "Latency to game servers and the cloud regions games run in, with a live TUI";
    homepage = "https://github.com/skippednote/gameping";
    license = lib.licenses.mit;
    mainProgram = "gameping";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
