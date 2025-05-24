{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ./profiles/sway-io.nix
  ];
  l3mon.sway = {
    workrooms.enable = true;
    outputs = [ "DP-1" "HDMI-A-1" ];
  };
}
