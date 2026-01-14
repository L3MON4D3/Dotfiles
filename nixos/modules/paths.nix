{ config, lib, pkgs, machine, data, ... }:

with lib;
{
  options = {
    l3mon.paths = {
      nixos_config_dir = mkOption {
        type = with types; nullOr str;
        description = mdDoc ''
          Location of git checkout of the nixos source.
        '';
        default = null;
      };
    };
  };
}
