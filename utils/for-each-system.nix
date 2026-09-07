{ inputs }: f:
let
  inherit (inputs.nixpkgs) lib;

  supportedSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
in
lib.genAttrs supportedSystems (
  system: f {
    pkgs = import inputs.nixpkgs { inherit system; };
  }
)
