{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/localnet.nix
    ];

  boot.loader.systemd-boot.enable = true;
}
