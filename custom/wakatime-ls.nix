{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "wakatime-ls";
  version = "0.1.10";

  src = pkgs.fetchFromGitHub {
    owner = "wakatime";
    repo = "zed-wakatime";
    rev = "v${version}";
    hash = "sha256-Jmm+eRHMNBkc6ZzadvkWrfsb+bwEBNM0fnXU4dJ0NgE=";
  };

  buildAndTestSubdir = "wakatime-ls";

  cargoHash = "sha256-x2axmHinxYZ2VEddeCTqMJd8ok0KgAVdUhbWaOdRA30=";
}
