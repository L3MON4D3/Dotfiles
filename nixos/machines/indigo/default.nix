{ config, lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/wireguard/netns.nix
      ../../modules/wireguard/host.nix

      ../../profiles/localnet.nix
      ../../profiles/qbittorrent.nix
      ../../profiles/radarr.nix
      ../../profiles/sonarr.nix

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
        port = data.network.lan."${machine}".service_ports.mysqld;
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /srv/media               0755 media media"
  ];
}
