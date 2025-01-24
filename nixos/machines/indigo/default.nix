{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/wireguard/netns.nix
      ../../modules/wireguard/host.nix
      ../../modules/restic.nix

      ../../profiles/localnet.nix
      ../../profiles/qbittorrent.nix
      ../../profiles/radarr.nix
      ../../profiles/sonarr.nix
      ../../profiles/jackett

      ../../profiles/kodi.nix
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

  services.nginx.enable = true;
  services.nginx.enableReload = true;

  users.users.media = {
    isSystemUser = true;
    uid = data.ids.media;
    group = "media";
  };
  users.groups.media.gid = data.ids.media;

  services.mysql = {
    enable = true; 
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        bind-address = "*";
        port = data.ports.mysql;
      };
    };
  };
  # indigo
  l3mon.restic = {
    enable = true;
    repo = {
      location = "/srv/restic-l3mon";
      passwordFile = "/var/secrets/restic-l3mon";
    };
    dailyBackupTime = "03:00:00";
    doRepoMaintenance = true;
    maintenanceExtra = [
      {
        text = ''echo Copying to B2!'';
      }
      {
        text = ''echo Copying to /mnt/misc!'';
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    config.l3mon.restic.wrapper
  ];
  environment.shellAliases = {
    lr = "l3mon-restic";
  };

  # enable restics allowOther-flag, so any user (eg simon) can access a
  # fuser-mounted directory.
  programs.fuse.userAllowOther = true;
  systemd.tmpfiles.rules = [
    "d /srv/media               0755 media media"
  ];
}
