{
  description = "Uses configuration.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=23e89b7da85c3640bbc2173fe04f4bd114342367";

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
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, plasma-manager, nix-index-database, ... }@inputs: {
    nixosConfigurations.krishnan-lap = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./krishnan-lap.nix

        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ sops-nix.homeManagerModules.sops plasma-manager.homeManagerModules.plasma-manager ];
          home-manager.users.krishnan.imports = [ ./home.nix ./krishnan-lap-home.nix ];
        }

        nix-index-database.nixosModules.nix-index
        {
          programs.nix-index-database.comma.enable = true;
        }
      ];
    };
    nixosConfigurations.krishnan-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./krishnan-pc.nix

        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ sops-nix.homeManagerModules.sops plasma-manager.homeManagerModules.plasma-manager ];
          home-manager.users.krishnan.imports = [ ./home.nix ./krishnan-pc-home.nix ];
        }

        nix-index-database.nixosModules.nix-index
        {
          programs.nix-index-database.comma.enable = true;
        }
      ];
    };
  };
}
