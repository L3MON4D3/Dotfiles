{
  description = "My NixOS config.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    netns-exec.url = "github:L3MON4D3/netns-exec";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    nixosConfigurations = let
      mkSimonConfig = machine_name: nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./configuration.nix
          ./machines/${machine_name}
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.simon = import ./home;
            home-manager.extraSpecialArgs = {
              inherit inputs nixpkgs-unstable;
              data = import ./data;
              l3lib = import ./lib.nix { pkgs = import inputs.nixpkgs { inherit system; }; };
              nur = inputs.nur.legacyPackages.${system};
            };
          }
          {
            _module.args = {
              inherit inputs system;
              data = import ./data;
              machine = machine_name;
              l3lib = import ./lib.nix { pkgs = import inputs.nixpkgs { inherit system; }; };
              nur = inputs.nur.legacyPackages.${system};
            };
          }
        ];
      };
    in {
      indigo = mkSimonConfig "indigo";
      carmine = mkSimonConfig "carmine";
    };
  };
}
