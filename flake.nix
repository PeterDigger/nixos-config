{

  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home manager
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.delicate = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        { nix.settings.experimental-features = ["nix-command" "flakes"]; }
        ./hosts/delicate/configuration.nix
        inputs.home-manager.nixosModules.default
        ./modules/docker/00-docker.nix
        ./modules/docker/01-homer.nix
        ./modules/docker/02-arr.nix
        ./modules/docker/03-media.nix
        ./modules/docker/04-storage.nix
        ./modules/docker/05-tools.nix
      ];
    };
    nixosConfigurations.brittle = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        { nix.settings.experimental-features = ["nix-command" "flakes"]; }
        ./hosts/brittle/configuration.nix
        inputs.home-manager.nixosModules.default
        ./modules/docker/00-docker.nix
        ./modules/docker/01-homer.nix
        ./modules/tools/00-dockerpull.nix
        ./modules/tools/01-temp.nix
        ./modules/tools/02-smartctl.nix
        ./modules/tools/03-smartctl-status.nix
        ./modules/tools/04-rebuild.nix
      ];
    };
  };
}
