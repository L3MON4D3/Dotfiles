{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/localnet.nix
      (import ../../modules/wireguard/host.nix data.network.wireguard_home)
    ];

  boot.loader.systemd-boot.enable = true;
}
