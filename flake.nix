{
  description = "Uses configuration.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # UEFI Secure Boot
    # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
  };

  outputs = { self, nixpkgs, lanzaboote, sops-nix, home-manager, plasma-manager, nix-index-database, nix-flatpak, ... }@inputs: {
    nixosConfigurations.krishnan-lap = nixpkgs.lib.nixosSystem {
      modules = [
        ./systems/krishnan-lap/configuration.nix

        lanzaboote.nixosModules.lanzaboote

        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ sops-nix.homeManagerModules.sops plasma-manager.homeModules.plasma-manager ];
          home-manager.users.krishnan.imports = [
            ./systems/krishnan-lap/home.nix
            nix-flatpak.homeManagerModules.nix-flatpak
          ];
        }

        nix-index-database.nixosModules.nix-index
        {
          programs.nix-index-database.comma.enable = true;
        }
      ];
    };
    nixosConfigurations.krishnan-pc = nixpkgs.lib.nixosSystem {
      modules = [
        ./systems/krishnan-pc/configuration.nix

        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ sops-nix.homeManagerModules.sops plasma-manager.homeModules.plasma-manager ];
          home-manager.users.krishnan.imports = [
            ./systems/krishnan-pc/home.nix
            nix-flatpak.homeManagerModules.nix-flatpak
          ];
        }

        nix-index-database.nixosModules.nix-index
        {
          programs.nix-index-database.comma.enable = true;
        }
      ];
    };
  };
}
