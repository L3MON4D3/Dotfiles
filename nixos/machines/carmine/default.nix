{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../modules/zotero.nix
    ../../modules/blocky.nix

    ../../profiles/simon.nix
    ../../profiles/localnet.nix
    ./hardware-configuration.nix

    ../../profiles/sway

    ../../profiles/firefox.nix

    ../../profiles/mxmaster3s.nix
    ../../profiles/unibonn.nix

    ./profiles/gamelibrary.nix
    ./profiles/cachefilesd.nix
    ./profiles/remarkable.nix
  ];

  environment.shellAliases = {
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#carmine"'';
  };

  fileSystems."/srv/misc" = {
    device = "indigo:/misc";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/srv/media" = {
    device = "indigo:/media";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/mnt/paperless" = {
    device = "indigo:/paperless-consume";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/mnt/data" = {
    device = "/dev/nvme0n1p8";
    fsType = "btrfs";
    options = [ "rw" ];
  };
  systemd.tmpfiles.rules = [
    "d /mnt/data 0750 simon simon"
  ];

  boot.loader.systemd-boot.enable = true;

  l3mon.network_namespaces = {
    enable = true;
    network_configs = [
      data.network.wireguard_home2
      data.network.wireguard_mullvad_de2
    ];
  };

  l3mon.zotero.enable_client = true;

  home-manager.sharedModules = [
    ({ config, lib, pkgs, machine, data, ... }: {
      l3mon.zotero.enable = true;
    })
  ];

  l3mon.restic = {
    enable = true;
    repo = {
      location = "rest:http://restic.internal/simon";
      passwordFile = "/var/secrets/restic-l3mon";
    };
  };

  hardware.keyboard.qmk.enable = true;

  services.dbus.implementation = "broker";

  nix.settings = {
    substituters = [
      "http://cache.indigo.internal"
    ];
    trusted-public-keys = [
      "cache.indigo.internal:CA2Hg9Xq3wNRTOU/Pombi0CLc2aemwlyPw/o34zDrKA="
    ];
  };

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  users.users.simon.extraGroups = [ "wireshark" ];
}
