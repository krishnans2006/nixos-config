# Note: This file is shared (symlinked) into multiple system directories (e.g. krishnan-lap, krishnan-pc).
# Any changes made here will affect all systems that use this shared configuration.
# Be very careful!

{ inputs, ... }:

with inputs;

nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };

  modules = [
    ./system.nix

    lanzaboote.nixosModules.lanzaboote

    sops-nix.nixosModules.sops

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ sops-nix.homeManagerModules.sops plasma-manager.homeModules.plasma-manager ];
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.krishnan.imports = [
        ./home.nix
        nix-flatpak.homeManagerModules.nix-flatpak
      ];
    }

    nix-index-database.nixosModules.nix-index
    {
      programs.nix-index-database.comma.enable = true;
    }
  ];
}
