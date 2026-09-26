# Note: This file is shared (symlinked) into multiple system directories.
# Any changes made here will affect all systems that use this common configuration.
# Be very careful!

{ inputs, root, ... }:

with inputs;

home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;

  extraSpecialArgs = {
    inherit (inputs) import-tree;
    inherit root;
  };

  modules = [
    # These are needed since they provide options used in modules/home
    # I don't think they can be easily removed, but I'm not sure if this is
    # even a concern (do they even take up storage space in the Nix store?)
    sops-nix.homeManagerModules.sops
    plasma-manager.homeModules.plasma-manager
    nix-flatpak.homeManagerModules.nix-flatpak

    nix-index-database.homeModules.nix-index
    {
      programs.nix-index-database.comma.enable = true;
    }

    ./home.nix
  ];
}
