{
  description = "My NixOS config.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
    nixpkgs-yuzu.url = "github:NixOS/nixpkgs?rev=125be29c4ef454788c42c28d49cb048ab0b5b548";
    nixpkgs-suyu.url = "github:NixOS/nixpkgs?rev=3730d8a308f94996a9ba7c7138ede69c1b9ac4ae";
    nixpkgs-ddns-updater-2-7.url = "github:NixOS/nixpkgs?rev=c792c60b8a97daa7efe41a6e4954497ae410e0c1";
    netns-exec.url = "github:L3MON4D3/netns-exec";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    nvim-browseredit.url = "github:l3mon4d3/nvim-browseredit";
    scientific-fhs.url = "github:l3mon4d3/scientific-fhs";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    merigold.url = "git+https://git.internal/simon/merigold.git";
    kiwix-seeder.url = "github:l3mon4d3/seeder";
    dirmap.url = "github:l3mon4d3/dirmap";
    didweb.url = "github:l3mon4d3/bsky-did-web";
    zotero-serve.url = "github:l3mon4d3/zotero-serve";
    jetls.url = "github:l3mon4d3/jetls-nix";
    dewclaw.url = "github:MakiseKurisu/dewclaw";
  };

  outputs = inputs@{ self, flake-utils, nixpkgs, nixpkgs-unstable, nixpkgs-yuzu, nixpkgs-suyu, nixpkgs-ddns-updater-2-7, home-manager, microvm, dewclaw, ... }: let
    mkSimonConfig = machine_name: system: {${machine_name} = nixpkgs.lib.nixosSystem (let
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in rec {
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
    });
  };
  mkOpenWRT = pkgs: machine_name: {
    ${machine_name} = pkgs.callPackage dewclaw ({
      configuration = { config, options, pkgs, lib, ... }: let
        dewclaw_option_names = [ "uci" "deploy" "deploySteps" "secretsCommand" "etc" "packages" "users" ];
      in {
        config._module.args = {
          inherit inputs pkgs self options config;
          lib = pkgs.lib;
          name = machine_name;
          # arbitrariliy use networks from carmine.
          networks = self.nixosConfigurations.carmine.config.lib.l3mon.networks;
          secrets = self.nixosConfigurations.carmine.config.secrets;
          data = import ./data;
        };
        imports = 
          (builtins.map (name: lib.mkAliasOptionModule [name] ["openwrt" machine_name name]) dewclaw_option_names) ++
          [
            ./openwrt/configuration.nix
            ./openwrt/machines/${machine_name}
            # enable lib config-part.
            ({ lib, ... }: {
              options = {
                lib = lib.mkOption {
                  default = { };

                  type = lib.types.attrsOf lib.types.attrs;

                  description = ''
                    This option allows modules to define helper functions, constants, etc.
                  '';
                };
              };
            })
          ];
      };
    });
  };
  in {
    nixosConfigurations = builtins.foldl' (acc: spec: acc // mkSimonConfig spec.name spec.system) {} [
      { name= "indigo"; system="x86_64-linux"; }
      { name="carmine"; system="x86_64-linux"; }
      { name= "indigo"; system="x86_64-linux"; }
    ];
  } // flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
  in {
    packages = builtins.foldl' (acc: name: acc // mkOpenWRT pkgs name) {} [ "ivory" "alabaster" ];
  });
}
