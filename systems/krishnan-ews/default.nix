{ inputs, ... }:

with inputs;

home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;

  extraSpecialArgs = {
    inherit (inputs) import-tree;
    root = self;
  };

  modules = [
    # These are needed since they provide options used in modules/home
    # I don't think they can be easily removed, but I'm not sure if this is
    # even a concern (do they even take up storage space in the Nix store?)
    sops-nix.homeManagerModules.sops
    plasma-manager.homeModules.plasma-manager
    nix-flatpak.homeManagerModules.nix-flatpak
    ./home.nix
  ];
}
