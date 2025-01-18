{ config, lib, pkgs, machine, data, ... }:

let
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
      Session\GlobalDLSpeedLimit=1800
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
      Downloads\SavePath=/mnt/downloads/
      Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\0)
      Downloads\StartInPause=false

      Queueing\MaxActiveDownloads=150
      Queueing\MaxActiveUploads=150
      Queueing\MaxActiveTorrents=150

      General\UseRandomPort=false

      MailNotification\enabled=false

      WebUI\Address=*
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
  systemd.services.qbittorrent_de = {
    enable = true;
    description = "Run qbittorrent in network namespace de";
    bindsTo = [ "network-online.target" "netns-${data.network.wireguard_mullvad_de.name}.service" ];
    after = [ "network-online.target" "netns-${data.network.wireguard_mullvad_de.name}.service" ];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "exec";
      # disable network-name-lookup via nscd and nsswitch, and provide
      # resolv.conf with vpn-provided dns.
      BindPaths = [
        "/var/empty:/var/run/nscd"
        # NetworkNamespacePath= does not mount /etc/netns/-provided files.
        # This is something done explicitly by `ip netns exec`.
        "/etc/netns/${data.network.wireguard_home.name}/resolv.conf:/etc/resolv.conf"
        "/etc/netns/${data.network.wireguard_home.name}/nsswitch.conf:/etc/nsswitch.conf"
      ];
      NetworkNamespacePath = "/var/run/netns/${data.network.wireguard_mullvad_de.name}";
    };
    serviceConfig = {
      User="qbittorrent";
      Group="qbittorrent";
    };
    script = ''
      # reset settings to default.
      mkdir -p /var/qbittorrent/qBittorrent/config/
      cp ${initial_qb_conf} /var/qbittorrent/qBittorrent/config/qBittorrent.conf

      ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/var/qbittorrent/
    '';
  };
  systemd.tmpfiles.rules = [
    "d /var/qbittorrent 0755 qbittorrent qbittorrent"
  ];
}
