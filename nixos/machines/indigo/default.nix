{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/localnet.nix
      ../../modules/wireguard/netns.nix
      ../../modules/wireguard/host.nix
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
  l3mon.wg-quick-hosts = {
    enable = true;
    network_configs = [
      data.network.wireguard_home2
    ];
  };
}
