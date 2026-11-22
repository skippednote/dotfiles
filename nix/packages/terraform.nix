# terraform from HashiCorp's prebuilt release rather than nixpkgs.
#
# terraform is BSL, so cache.nixos.org does not carry it and every nixpkgs
# bump rebuilds it from source. That build runs the Go test suite, which
# compiles a test binary per package and needed more than 14 GB of scratch
# space - it failed with "no space left on device" on 1.17.1.
#
# To bump: change the version, then get the hash with
#
#   nix store prefetch-file https://releases.hashicorp.com/terraform/X.Y.Z/terraform_X.Y.Z_darwin_arm64.zip
#
# and check it against terraform_X.Y.Z_SHA256SUMS on the same page.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "terraform";
  version = "1.17.2";

  src = fetchurl {
    url = "https://releases.hashicorp.com/terraform/${finalAttrs.version}/terraform_${finalAttrs.version}_darwin_arm64.zip";
    hash = "sha256-2gx+8nipETR4YnWOdXOlkHNl5mSFwmN89cIXxeInmS4=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 terraform $out/bin/terraform
    runHook postInstall
  '';

  meta = {
    description = "Infrastructure as code tool, from HashiCorp's prebuilt binary";
    homepage = "https://www.terraform.io";
    license = lib.licenses.bsl11;
    mainProgram = "terraform";
    platforms = [ "aarch64-darwin" ];
  };
})
