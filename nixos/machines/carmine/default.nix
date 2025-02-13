{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../profiles/simon.nix
    ../../profiles/localnet.nix
    ./hardware-configuration.nix

    ../../profiles/sway

    ../../profiles/firefox.nix

    ../../profiles/mxmaster3s.nix
  ];

  environment.shellAliases = {
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#carmine"'';
  };

  fileSystems."/srv/misc" = {
    device = "indigo:/misc";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };
  fileSystems."/srv/media" = {
    device = "indigo:/media";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };

  boot.loader.systemd-boot.enable = true;

  l3mon.network_namespaces = {
    enable = true;
    network_configs = [
      data.network.wireguard_home2
      data.network.wireguard_mullvad_de2
    ];
  };

  services.dbus.implementation = "broker";
}
