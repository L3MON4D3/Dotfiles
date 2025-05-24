{ config, lib, pkgs, machine, data, ... }:

with lib;
{
  options.l3mon.sway = {
    outputs = mkOption {
      type = lib.types.listOf (lib.types.str);
      default = [];
      description = ''
        Identifiers for all outputs.
      '';
    };
  };
}
