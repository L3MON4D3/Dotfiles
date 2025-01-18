{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/localnet.nix
      ../../modules/wireguard/netns.nix
      (import ../../modules/wireguard/host.nix data.network.wireguard_home2)
      ../../modules/qbittorrent.nix
    ];

  boot.loader.systemd-boot.enable = true;
  l3mon.network_namespaces = {
    enable = true;
    network_configs = [
      data.network.wireguard_home
      data.network.wireguard_mullvad_de
    ];
  };
}
