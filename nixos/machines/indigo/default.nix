{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/localnet.nix
      (import ../../modules/wireguard/host.nix data.network.wireguard_home2)
      (import ../../modules/wireguard/netns.nix data.network.wireguard_mullvad_de)
      (import ../../modules/wireguard/netns.nix data.network.wireguard_home)
      ../../modules/qbittorrent.nix
    ];

  boot.loader.systemd-boot.enable = true;
}
