{ inputs, ... }:

with inputs;

nixpkgs.lib.nixosSystem {
  modules = [
    ./configuration.nix

    lanzaboote.nixosModules.lanzaboote

    sops-nix.nixosModules.sops

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ sops-nix.homeManagerModules.sops plasma-manager.homeModules.plasma-manager ];
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
