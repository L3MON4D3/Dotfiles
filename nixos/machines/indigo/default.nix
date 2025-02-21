{ config, lib, l3lib, pkgs, data, machine, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../profiles/simon.nix

      ../../profiles/localnet.nix
      ../../profiles/qbittorrent.nix
      ../../profiles/radarr.nix
      ../../profiles/sonarr.nix
      ../../profiles/jackett

      # ../../profiles/kodi.nix
      ../../profiles/jellyfin.nix

      ../../profiles/samba.nix
      ../../profiles/radicale.nix
      ../../profiles/webdav.nix

      ../../profiles/blocky.nix

      # ../../profiles/cachefilesd.nix
      ../../profiles/ddns-updater.nix
      ../../profiles/errormail.nix

      ../../profiles/nfs.nix
      ../../profiles/game-library.nix

      ../../profiles/forgejo.nix

      ../../profiles/immich.nix
      ../../profiles/paperless.nix

      ../../profiles/rmfakecloud.nix

      ../../profiles/kimmify.nix

      ../../modules/zotero.nix

      ../../profiles/unibonn.nix

      ../../profiles/cache.nix
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

  services.caddy.enable = true;
  services.caddy.enableReload = true;

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
    enable_server = true;
    repo = {
      location = "/srv/restic-l3mon";
      passwordFile = l3lib.secret "restic-l3mon";
    };
    dailyBackupTime = "03:00:00";
    doRepoMaintenance = true;
    maintenanceExtra = [
      {
        text = ''
          ${pkgs.rsync}/bin/rsync -rpt --progress --size-only --delete /srv/restic-l3mon /mnt/glacier/restic-l3mon
        '';
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

  # mount large storage.
  fileSystems."/mnt/torrent" = {
    label = "torrent";
    options = ["rw"];
  };

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  networking.hostId = "0c6280a2";

  boot.zfs.extraPools = ["glacier"];

  services.zfs.autoScrub = {
    enable = true;
    interval = "Wed 03:00:00";
  };

  services.zfs.trim = {
    enable = true;
    interval = "Thu 03:00:00";
  };

  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "simljk@outlook.de" ];
    # use wrapper!
    ZED_EMAIL_PROG = "${config.security.wrapperDir}/sendmail";
    ZED_EMAIL_OPTS = " @ADDRESS@";

    # at most every ten minutes.
    ZED_NOTIFY_INTERVAL_SECS = 60*10;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = false;
    ZED_SCRUB_AFTER_RESILVER = true;
  };
  # not recommended? No matter, the above works well :)
  services.zfs.zed.enableMail = false;

  # requires that com.sun:auto-snapshot is enabled on datasets.
  # TODO: look into sanoid or some other more granular solution for this.
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
    frequent = 0;
    hourly = 0;
    # only keep snapshot for last seven days, this is mainly to prevent
    # accidental deletion.
    daily = 7;
    weekly = 0;
    monthly = 0;
  };

  # # bind-mount storage into place where stuff should not be stored on the main drive.
  fileSystems."/srv/media" = {
    device = "/mnt/glacier/media";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };
  fileSystems."/srv/misc" = {
    device = "/mnt/glacier/misc";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };
  

  #
  # Bind-mounts for services!
  #

  # # qbittorrent
  fileSystems."/var/lib/qbittorrent/qBittorrent/downloads" = {
    device = "/mnt/torrent/downloads";
    options = [ "bind" ];
  };

  # # restic
  fileSystems."/srv/restic-l3mon" = {
    device = "/mnt/torrent/restic-l3mon";
    options = [ "bind" ];
  };

  # # immich
  fileSystems."/var/lib/immich" = {
    device = "/mnt/torrent/immich";
    options = [ "bind" ];
  };

  # # samba
  fileSystems."/srv/samba/christel" = {
    device = "/mnt/glacier/samba/christel";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };

  # # game-library
  fileSystems."/var/lib/steam/library" = {
    device = "/mnt/glacier/games/steamlib";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };
  fileSystems."/srv/games/gog" = {
    device = "/mnt/glacier/games/gog";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };
  fileSystems."/srv/zotero" = {
    device = "/mnt/glacier/misc/zotero/data";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };


  # nfs
  fileSystems."/srv/nfs/media" = {
    device = "/mnt/glacier/media";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };
  fileSystems."/srv/nfs/misc" = {
    device = "/mnt/glacier/misc";
    options = [ "bind" "x-systemd.requires=zfs-mount.service" ];
  };
  services.nfs.server.exports = ''
    /srv/nfs/media 192.168.178.0/24(rw,fsid=b8cf27e6-4514-419d-85c3-9cb6eecd1a76,no_root_squash)
    /srv/nfs/misc 192.168.178.0/24(rw,fsid=b833bef7-1307-4a3e-a580-258b21f51770,no_root_squash)
  '';

  # set gid-bit on media-directories so files are created with group media.
  # set default-permissions so write is allowed for all group-members.
  # systemd.tmpfiles.rules = [
    # "d /srv/media                2775 media  media"
    # "A /srv/media                -    -      -       -   d:u:media:rwX"
    # "d /srv/media/audio          2775 media  media"
    # "d /srv/media/video          2775 media  media"
    # "d /srv/media/video/shows    2775 media  media"
    # "d /srv/media/video/movies   2775 media  media"

    # "d /mnt/glacier/restic-l3mon 0750 restic restic"
  # ];

  services.dbus.implementation = "broker";
  l3mon.zotero.enable_server = true;

  environment.shellAliases = {
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#indigo"'';
  };
}
