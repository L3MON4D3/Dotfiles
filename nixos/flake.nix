{
  description = "My NixOS config.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-yuzu.url = "github:NixOS/nixpkgs?rev=125be29c4ef454788c42c28d49cb048ab0b5b548";
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
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    mpdlrc.url = "github:l3mon4d3/mpdlrc";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nixpkgs-yuzu, home-manager, ... }: {
    nixosConfigurations = let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      mkSimonConfig = machine_name: nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {
          inherit pkgs-unstable;
          pkgs-yuzu = import nixpkgs-yuzu {
            inherit system;
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
              inherit inputs pkgs-unstable;
              data = import ./data;
              l3lib = import ./lib.nix { pkgs = import inputs.nixpkgs { inherit system; }; };
              nur = inputs.nur.legacyPackages.${system};
            };
          }
          {
            _module.args = {
              inherit inputs system self;
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
      cobalt = mkSimonConfig "cobalt";
    };
  };
}
