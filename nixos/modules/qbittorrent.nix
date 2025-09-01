{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

with lib;
let
    cfg = config.l3mon.qbittorrent;
in {
  # provide torrent-directory globally.
  options.l3mon.qbittorrent = {
    enable = mkEnableOption (lib.mdDoc "Enable qbittorrent.");
    finish_scripts = mkOption {
      type = with types; listOf str;
      description = lib.mdDoc "Path to scripts which are executed once a torrent is finished, with various env-variables relating to it.";
      default = [];
    };
    # add_scripts = mkOption {
      # type = with types; listOf str;
      # description = lib.mdDoc "Path to scripts which are executed once a torrent is added, with various env-variables relating to it.";
      # default = [];
    # };
    category_savepaths = mkOption {
      type = types.attrsOf types.string;
      description = lib.mdDoc "Map category name to savepath. Set to \"\" for the default-path.";
      default = {};
    };
  };

  config = mkIf cfg.enable (let
    qb_statedir = "/var/lib/qbittorrent";
    wg_network = data.network.wireguard_mullvad_de;
    wg_machine_conf = wg_network.peers."${machine}";
    qb_port = data.ports.qbittorrent;
    torrent_script_vars =
      # bash
      ''
        export QB_NAME=''${1}          # Torrent Name
        export QB_CATEGORY=''${2}      # Category
        export QB_TAGS=''${3}          # Tags (separated by comma)
        export QB_CONTENT_PATH=''${4}  # Content Path (same as root path for multifile torrent)
        export QB_ROOT_PATH=''${5}     # Root path (first torrent subdirectory path)
        export QB_SAVE_PATH=''${6}     # Save Path
        export QB_NUM_FILES=''${7}     # Numbe of files
        export QB_NUM_BYTES=''${8}     # Torrent size in bytes
        export QB_TRACKER=''${9}       # Current tracker     
        export QB_INFOHASH1=''${10}    # Info hash v1
        export QB_INFOHASH2=''${11}    # Info hash v2
      '';
    torrent_script_params = ''\"%N\" \"%L\" \"%G\" \"%F\" \"%R\" \"%D\" \"%C\" \"%Z\" \"%T\" \"%I\" \"%J\" \"%K\"'';
    # add_script = pkgs.writeShellApplication {
      # name = "qb-add";
      # text = torrent_script_vars + "\n" + lib.strings.concatLines cfg.add_scripts;
    # } + "/bin/qb-add";
    finish_script = pkgs.writeShellApplication {
      name = "qb-finish";
      text = torrent_script_vars + "\n" + (lib.strings.concatLines cfg.finish_scripts);
    } + "/bin/qb-finish";
    initial_categories = pkgs.writeTextFile {
      name = "qbcat";
      text = lib.strings.toJSON (builtins.mapAttrs (k: v: {save_path = v;}) cfg.category_savepaths);
    };
    initial_qb_conf = pkgs.writeTextFile {
      name = "qbconf";
      text = ''
        [BitTorrent]
        Session\CreateTorrentSubfolder=true
        Session\DisableAutoTMMByDefault=false
        Session\DisableAutoTMMTriggers\CategoryChanged=false
        Session\DisableAutoTMMTriggers\CategorySavePathChanged=false
        Session\DisableAutoTMMTriggers\DefaultSavePathChanged=false
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
        WebUI\Port=${toString qb_port}
        WebUI\AlternativeUIEnabled=false
        WebUI\CSRFProtection=false
        WebUI\ClickjackingProtection=true
        WebUI\HTTPS\Enabled=false
        WebUI\HostHeaderValidation=true
        WebUI\UseUPnP=false
        WebUI\LocalHostAuth=false
        WebUI\AuthSubnetWhitelist=192.168.178.0/24, 10.0.0.0/24
        WebUI\AuthSubnetWhitelistEnabled=true

        [AutoRun]
        # OnTorrentAdded\Enabled=true
        # OnTorrentAdded\Program=''${add_script} ''${torrent_script_params}
        enabled=true
        program=${finish_script} ${torrent_script_params}
      '';
    };
  in {
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
          # create these as modifiable. This means qbittorrent can always
          # create more categories/configs, but these will be reset on the next
          # reboot.

          install -D -o qbittorrent -g qbittorrent ${initial_qb_conf} ${qb_statedir}/qBittorrent/config/qBittorrent.conf
          install -D -o qbittorrent -g qbittorrent ${initial_categories} ${qb_statedir}/qBittorrent/config/categories.json

          chown qbittorrent:qbittorrent \
            ${qb_statedir} \
            ${qb_statedir}/qBittorrent \
            ${qb_statedir}/qBittorrent/config
        '';
      };
    };

    services.caddy.extraConfig = ''
      http://qbittorrent, http://qbittorrent.internal, http://qbittorrent.${machine} {
        reverse_proxy http://${wg_machine_conf.local.address}:${toString qb_port}
      }
    '';

    systemd = let
      qb_control = pkgs.writers.writePython3 "qb_control" {
        libraries = [ pkgs.python3Packages.qbittorrent-api ];
      } ''
        import qbittorrentapi
        from enum import Enum
        from functools import reduce

        client = qbittorrentapi.Client(host="qbittorrent.internal:80")


        class QBTTorrent:
            def __init__(self, hash=None):
                assert hash
                self.hash = hash

            @classmethod
            def from_hash(cls, hash):
                return cls(hash=hash)

            def stop(self):
                client.torrents_stop(self.hash)

            def info(self):
                return client.torrents_info(torrent_hashes=self.hash)[0]

            def limit_download(self):
                client.torrents_set_download_limit(torrent_hashes=self.hash, limit=1)

            def unlimit_download(self):
                client.torrents_set_download_limit(torrent_hashes=self.hash, limit=-1)


        class APITorrentState(Enum):
            ERROR = "error"
            MISSING_FILES = "missingFiles"
            UPLOADING = "uploading"
            STOPPED_UPLOAD = "stoppedUP"
            QUEUED_UPLOAD = "queuedUP"
            STALLED_UPLOAD = "stalledUP"
            CHECKING_UPLOAD = "checkingUP"
            FORCED_UPLOAD = "forcedUP"
            ALLOCATING = "allocating"
            DOWNLOADING = "downloading"
            METADATA_DOWNLOAD = "metaDL"
            FORCED_METADATA_DOWNLOAD = "forcedMetaDL"
            STOPPED_DOWNLOAD = "stoppedDL"
            QUEUED_DOWNLOAD = "queuedDL"
            FORCED_DOWNLOAD = "forcedDL"
            STALLED_DOWNLOAD = "stalledDL"
            CHECKING_DOWNLOAD = "checkingDL"
            CHECKING_RESUME_DATA = "checkingResumeData"
            MOVING = "moving"
            UNKNOWN = "unknown"


        # not sure about the statuses here..
        def get_torrents(state, category):
            return reduce(
                lambda list, info:
                    list + ([QBTTorrent.from_hash(info.hash)]
                            if info.state in state else []),
                client.torrents_info(category=category), [])


        # only stop if movie is actually downloading!
        movie_downloading_states = frozenset({
            APITorrentState.FORCED_DOWNLOAD.value,
            APITorrentState.DOWNLOADING.value
        })

        # collect states to stop.
        aa_downloading_states = frozenset({
            APITorrentState.FORCED_DOWNLOAD.value,
            APITorrentState.STALLED_DOWNLOAD.value,
            APITorrentState.DOWNLOADING.value
        })

        
        priority_dl_torrents = get_torrents(movie_downloading_states, "radarr") + get_torrents(movie_downloading_states, "tv-sonarr")  # noqa: E501.
        if len(priority_dl_torrents) > 0:
            for t in get_torrents(aa_downloading_states, "aa"):
                t.limit_download()
        else:
            for t in get_torrents(aa_downloading_states, "aa"):
                t.unlimit_download()
      '';
    in {
      tmpfiles.rules = [
        "d    ${qb_statedir}  0750    qbittorrent qbittorrent"
        "Z    ${qb_statedir}  0750    qbittorrent qbittorrent"
      ];
      timers.qb_control = {
        enable = true;
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "5min";
          OnUnitInactiveSec = "1min";
          Unit = "qb_control.service";
        };
      };
      services = {
        qb_control = {
          requires = ["qbittorrent_de.service"];
          serviceConfig = {
            Type = "oneshot";
            dynamicUser = true;
          };
          script = ''
            ${qb_control}
          '';
        };
        qbittorrent_de = config.l3mon.network_namespaces.mkNetnsService wg_network {
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
      };
    };

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
  });
}
