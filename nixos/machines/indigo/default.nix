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
      ../../profiles/jellyfin.nix

      ../../profiles/blocky.nix

      # ../../profiles/cachefilesd.nix
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

  users.users.media = {
    isSystemUser = true;
    uid = data.ids.media;
    group = "media";
  };
  users.groups.media.gid = data.ids.media;


  # for now, need some way to access large storage devices.
  fileSystems."/mnt/.misc" = {
    device = "cinnabar:/misc";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };

  # replace these with actual physical drive-mounts.
  fileSystems."/mnt/glacier" = {
    depends = ["/mnt/.misc"];
    device = "/mnt/.misc/indigo_disks/glacier_img";
    label = "glacier";
    options = [ "rw" "_netdev"];
  };
  fileSystems."/mnt/torrent" = {
    depends = ["/mnt/.misc"];
    device = "/mnt/.misc/indigo_disks/torrent_img";
    label = "torrent";
    options = [ "rw" "_netdev"];
  };

  # bind-mount storage into place where stuff should not be stored on the main drive.
  fileSystems."/srv/media" = {
    depends = ["/mnt/glacier"];
    device = "/mnt/glacier/media";
    options = [ "rw" "_netdev" "bind" ];
  };
  fileSystems.${config.l3mon.qbittorrent.torrentDir} = {
    depends = ["/mnt/torrent"];
    device = "/mnt/torrent/downloads";
    options = [ "rw" "_netdev" "bind" ];
  };
  
  fileSystems."/srv/restic-l3mon" = {
    depends = ["/mnt/torrent"];
    device = "/mnt/torrent/restic-l3mon";
    options = [ "rw" "_netdev" "bind" ];
  };
  l3mon.restic.dailyRequiredServices = ["srv-restic${''\''}x2dl3mon.mount"];

  # set gid-bit on media-directories so files are created with group media.
  # set default-permissions so write is allowed for all group-members.
  systemd.tmpfiles.rules = [
    "d  /srv/media                              2775    media   media"
    "A  /srv/media                              -       -       -       -   d:u:media:rwX"
    "d  /srv/media/audio                        2775    media   media"
    "d  /srv/media/video                        2775    media   media"
    "d  /srv/media/video/shows                  2775    media   media"
    "d  /srv/media/video/movies                 2775    media   media"
  ];

  # enable restics allowOther-flag, so any user (eg simon) can access a
  # fuser-mounted directory.
  programs.fuse.userAllowOther = true;
}
