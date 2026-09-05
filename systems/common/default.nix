# Note: This file is common (symlinked) into multiple system directories (e.g. krishnan-lap, krishnan-pc).
# Any changes made here will affect all systems that use this common configuration.
# Be very careful!

{ inputs, ... }:

with inputs;

nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    inherit (inputs) import-tree;
    root = inputs.self;
  };

  modules = [
    ./system.nix

    disko.nixosModules.disko
    impermanence.nixosModules.impermanence
    lanzaboote.nixosModules.lanzaboote
    sops-nix.nixosModules.sops

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        inherit (inputs) import-tree;
        root = inputs.self;
      };

      home-manager.sharedModules = [
        sops-nix.homeManagerModules.sops
        plasma-manager.homeModules.plasma-manager
        nix-flatpak.homeManagerModules.nix-flatpak
      ];

      home-manager.users.krishnan.imports = [ ./home.nix ];
    }

    nix-index-database.nixosModules.nix-index
    {
      programs.nix-index-database.comma.enable = true;
    }
  ];
}
