{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

with lib;
let
  qb_statedir = "/var/lib/qbittorrent";
  wg_network = data.network.wireguard_mullvad_de;
  wg_machine_conf = wg_network.peers."${machine}";
  qb_port = data.ports.qbittorrent;
  initial_qb_conf = pkgs.writeTextFile {
    name = "qbconf";
    text = ''
      [BitTorrent]
      Session\CreateTorrentSubfolder=true
      Session\DisableAutoTMMByDefault=true
      Session\DisableAutoTMMTriggers\CategoryChanged=false
      Session\DisableAutoTMMTriggers\CategorySavePathChanged=true
      Session\DisableAutoTMMTriggers\DefaultSavePathChanged=true
      Session\AnonymousModeEnabled=true

      Session\AlternativeGlobalDLSpeedLimit=0
      Session\AlternativeGlobalUPSpeedLimit=200
      Session\GlobalDLSpeedLimit=2000
      Session\GlobalUPSpeedLimit=100

      Session\BandwidthSchedulerEnabled=true

      Session\ValidateHTTPSTrackerCertificate=false

      [Core]
      AutoDeleteAddedTorrentFile=Never

      [LegalNotice]
      Accepted=true

      [Network]
      Cookies=@Invalid()

      [Preferences]
      Advanced\AnonymousMode=true

      Bittorrent\AddTrackers=false
      Bittorrent\MaxRatioAction=0
      Bittorrent\PeX=true

      Scheduler\days=EveryDay
      Scheduler\end_time=@Variant(\0\0\0\xf\x1I\x97\0)
      Scheduler\start_time=@Variant(\0\0\0\xf\0n\xc7`)

      Downloads\PreAllocation=false
      Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\0)
      Downloads\StartInPause=false

      Queueing\MaxActiveDownloads=150
      Queueing\MaxActiveUploads=150
      Queueing\MaxActiveTorrents=150

      General\UseRandomPort=false

      MailNotification\enabled=false

      WebUI\Address=*
      WebUI\Port=${qb_port}
      WebUI\AlternativeUIEnabled=false
      WebUI\CSRFProtection=false
      WebUI\ClickjackingProtection=true
      WebUI\HTTPS\Enabled=false
      WebUI\HostHeaderValidation=true
      WebUI\UseUPnP=false
      WebUI\LocalHostAuth=false
      WebUI\AuthSubnetWhitelist=192.168.178.0/24, 10.0.0.0/24
      WebUI\AuthSubnetWhitelistEnabled=true
    '';
  };
in
{
  config = {
    # qbittorrent needs to store data -> needs a users.
    users.users.qbittorrent = {
      isSystemUser = true;
      uid = data.ids.qbittorrent;
      group = "qbittorrent";
    };
    users.groups.qbittorrent.gid = data.ids.qbittorrent;

    system.activationScripts = {
      qbittorrent = {
        text = ''
          install -D -o qbittorrent -g qbittorrent ${initial_qb_conf} ${qb_statedir}/qBittorrent/config/qBittorrent.conf
          chown qbittorrent:qbittorrent \
            ${qb_statedir} \
            ${qb_statedir}/qBittorrent \
            ${qb_statedir}/qBittorrent/config
        '';
      };
    };


    systemd.services.qbittorrent_de = config.l3mon.network_namespaces.mkNetnsService wg_network {
      enable = true;
      description = "Run qbittorrent in network namespace de";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "exec";
      };
      serviceConfig = {
        User="qbittorrent";
        Group="qbittorrent";
      };
      script = ''
        ${pkgs-unstable.qbittorrent-nox.overrideAttrs(old: {
          patches = [
            ./qbt_subpiece_progress.patch
          ];
        })}/bin/qbittorrent-nox --profile=${qb_statedir}
      '';
    };
    systemd.tmpfiles.rules = [
      "d    ${qb_statedir}  0750    qbittorrent qbittorrent"
      "Z    ${qb_statedir}  0750    qbittorrent qbittorrent"
    ];
    
    services.caddy.extraConfig = ''
      http://qbittorrent, http://qbittorrent.internal, http://qbittorrent.${machine} {
        reverse_proxy http://${wg_machine_conf.local.address}:${qb_port}
      }
    '';

    l3mon.restic.extraGroups = [ "qbittorrent" ];
    l3mon.restic.specs.qbittorrent = {
      backupDaily = {
        text = ''
          cd ${qb_statedir}/qBittorrent/data/BT_backup
          if ls ./*.torrent &> /dev/null; then
            restic backup --tag=qbittorrents --skip-if-unchanged=true -- *.torrent 
          fi
        '';
      };
      forget = {
        text = ''
          # For each known file (torrent), keep last snapshot where it existed.
          # This makes sure every torrent-file still exists somewhere in the restic-repository.
          restic forget --tag=qbittorrents --group-by="tag,path" --keep-last=1
        '';
      };
    };
  };

  # provide torrent-directory globally.
  options.l3mon.qbittorrent.torrentDir = mkOption {
    type = with types; path;
    description = "Path to torrent-directory.";
    default = "${qb_statedir}/qBittorrent/downloads";
  };
}
