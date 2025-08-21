{ config, lib, pkgs, machine, inputs, data, system, microvm, ... }:

{
  microvm = {
    vms = {
      merigold = {
        # use same packages as flake.
        pkgs = import inputs.merigold.inputs.nixpkgs {inherit system;};
        config = inputs.merigold.nixosModules.${system}.merigold;
        specialArgs.mgconf = {
          hostname = "merigold";
        };
      };
    };
  };
}
