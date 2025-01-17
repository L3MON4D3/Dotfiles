{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/localnet.nix
      (import ../../modules/wireguard/host.nix data.network.wireguard_home)
      (import ../../modules/wireguard/netns.nix data.network.wireguard_mullvad_de)
      ../../modules/qbittorrent.nix
    ];

  boot.loader.systemd-boot.enable = true;
}
