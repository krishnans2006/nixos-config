{ inputs, ... }:

with inputs;

home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  extraSpecialArgs = {
    inherit (inputs) import-tree;
    root = inputs.self;
  };

  modules = [
    # These are needed since they provide options used in modules/home
    # I don't think they can be easily removed, but I'm not sure if this is
    # even a concern (do they even take up storage space in the Nix store?)
    inputs.sops-nix.homeManagerModules.sops
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./home.nix
  ];
}
