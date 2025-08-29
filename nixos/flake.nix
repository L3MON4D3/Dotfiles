{
  description = "My NixOS config.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-yuzu.url = "github:NixOS/nixpkgs?rev=125be29c4ef454788c42c28d49cb048ab0b5b548";
    nixpkgs-suyu.url = "github:NixOS/nixpkgs?rev=3730d8a308f94996a9ba7c7138ede69c1b9ac4ae";
    nixpkgs-ddns-updater-2-7.url = "github:NixOS/nixpkgs?rev=c792c60b8a97daa7efe41a6e4954497ae410e0c1";
    netns-exec.url = "github:L3MON4D3/netns-exec";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
    aa-torrent-dl.url = "github:l3mon4d3/aa-torrent-dl";
    scientific-fhs.url = "github:l3mon4d3/scientific-fhs";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    merigold.url = "git+http://git.internal/simon/merigold.git";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nixpkgs-yuzu, nixpkgs-suyu, nixpkgs-ddns-updater-2-7, home-manager, microvm, merigold, ... }: {
    nixosConfigurations = let
      pkgs = import nixpkgs { inherit system; };
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
          pkgs-suyu = import nixpkgs-suyu {
            inherit system;
          };
          pkgs-ddns-updater-2-7 = import nixpkgs-ddns-updater-2-7 {
            inherit system;
          };
          patched_wpa_supplicant = pkgs.runCommand "patched-wpa-supplicant" {} ''
            mkdir -p $out
            echo ${nixpkgs.outPath}
            cp ${nixpkgs.outPath}/nixos/modules/services/networking/wpa_supplicant.nix $out/wpa_supplicant.nix
            patch -p1 $out/wpa_supplicant.nix ${./.}/data/patches/mac_hooks.patch
          '';
        };
        modules = [
          ./configuration.nix
          ./machines/${machine_name}
          microvm.nixosModules.host
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.simon = import ./home;
            home-manager.extraSpecialArgs = {
              inherit inputs pkgs-unstable;
              data = import ./data;
              l3lib = import ./lib.nix { inherit pkgs; };
              nur = inputs.nur.legacyPackages.${system};
              aa-torrent-dl = inputs.aa-torrent-dl.packages.${system};
              scientific-fhs = inputs.scientific-fhs.packages.${system}.scientific-fhs;
            };
          }
          {
            _module.args = {
              inherit inputs system self;
              data = import ./data;
              machine = machine_name;
              l3lib = import ./lib.nix { inherit pkgs; };
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
