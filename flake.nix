{
  description = "Unified NixOS and Darwin System Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nixvim, lanzaboote, sops-nix, plasma-manager, ... }:
  let 
    specialArgs = { inherit inputs home-manager self plasma-manager; };
  in {
    darwinConfigurations."zhaochanglongdeMacBook-Air" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      inherit specialArgs;
      modules = [
        ./darwin
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zhaochanglong = import "${self}/shared/home";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = "bak";
        }
      ];
    };

    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit specialArgs;
      modules = [
        ./nixos
        lanzaboote.nixosModules.lanzaboote
        sops-nix.nixosModules.sops
      ];
    };
  };
}
