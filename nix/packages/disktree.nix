# disktree from source. Upstream ships no flake, and nixpkgs' package is
# Linux-only (meta.platforms), so pkgs.disktree refuses to evaluate here.
#
# disktree is a GPUI treemap written for Omarchy. Upstream targets Linux only
# and publishes one x86_64-linux tarball, but GPUI has a macOS backend and the
# app builds and runs on aarch64-darwin as-is: the core tests pass and the
# window opens. The Linux libraries and rpath fixup below are therefore
# Linux-only; on Darwin GPUI needs nothing beyond the SDK stdenv provides.
#
# One macOS gap: "Move to trash" knows only Linux trash tools (trash-put, gio),
# so here it falls back to ~/.local/share/Trash rather than the Finder Trash.
# Permanent removal is unaffected.
#
# Every crate is on crates.io (no git sources in Cargo.lock), so cargoHash is
# enough and no lock file needs copying into this repo.
#
# To bump: change the version, then
#
#   nix flake prefetch github:tobi/disktree/vX.Y.Z    # "hash" -> src.hash
#
# and set cargoHash to "" - the build failure prints the real value.
#
# Linux native deps are the ones the Linux dependency graph links, not upstream's
# apt list: freetype-sys, yeslogic-fontconfig-sys, the x11 and xkbcommon
# crates, and wayland-sys. TLS is rustls, so no openssl. The rpath fixup is
# nixpkgs' zed-editor recipe (the same GPUI stack): wgpu dlopens libvulkan and
# wayland-sys dlopens libwayland-client, so neither is in the ELF's NEEDED and
# the auto rpath from buildInputs does not cover them.
{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  fontconfig,
  freetype,
  libxkbcommon,
  vulkan-loader,
  wayland,
  libx11,
  libxcb,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "disktree";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "disktree";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b7VP3VgOS+zUTR2bhOh6JNcN5mIIeHL/fe3u/eHC+X4=";
  };

  cargoHash = "sha256-k+iLvOS+6o5oC+JcG9BJ3UUAzZAQpcpNelKCXsDx0Fw=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
    freetype
    libxkbcommon
    wayland
    libx11
    libxcb
  ];

  # The workspace also carries xtask, a dev-only helper. Build the app alone,
  # as upstream's release.yml does.
  cargoBuildFlags = [
    "-p"
    "disktree-app"
  ];

  # `cargo xtask test` runs the core tests plus a window harness that needs a
  # display. Only the core crate can run in the sandbox.
  cargoTestFlags = [
    "-p"
    "disktree-core"
  ];

  # Asserts the real home directory sits on the root volume, which the build
  # sandbox's HOME does not.
  checkFlags = [
    "--skip=space::tests::the_home_disk_on_macos_is_the_root_and_has_a_device"
  ];

  # The same three files upstream's `make install` / install.sh put in place:
  # binary, desktop entry and icon, with the entry pointing at the store path.
  postInstall = ''
    install -Dm644 assets/disktree.svg \
      $out/share/icons/hicolor/scalable/apps/disktree.svg
    sed -e "s|@BINDIR@|$out/bin|" -e "s|@VERSION@|${finalAttrs.version}|" \
      packaging/disktree.desktop.in > disktree.desktop
    install -Dm644 disktree.desktop $out/share/applications/disktree.desktop
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/disktree --add-rpath ${
      lib.makeLibraryPath [
        vulkan-loader
        wayland
      ]
    }
  '';

  meta = {
    description = "Treemap for finding and removing what fills your disk";
    homepage = "https://github.com/tobi/disktree";
    license = lib.licenses.mit;
    mainProgram = "disktree";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
