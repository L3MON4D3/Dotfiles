{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  indigo_lan_address = data.network.lan.peers.${machine}.address;
in {
  services.jellyfin.enable = true;
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  
  services.nginx.virtualHosts.jellyfin = {
    serverName = "jellyfin jellyfin.internal jellyfin.${machine}";
    locations = {
      "/" = {
        proxyPass = "http://${indigo_lan_address}:${data.ports.jellyfin_web}";
        recommendedProxySettings = true;
      };
      "/socket" = {
        proxyPass = "http://${indigo_lan_address}:${data.ports.jellyfin_web}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };
  };

  users.users.restic.extraGroups = [ "jellyfin" ];
  # allow group read-access so restic can read everything.
  systemd.services.jellyfin.serviceConfig.UMask = mkForce 0027;
  l3mon.restic = {
    dailyStopResumeServices = ["jellyfin.service"];
    specs.jellyfin = {
      # stop jellyfin while backup is running, then resume.
      backupDaily = {
        text = ''
          cd ${config.services.jellyfin.dataDir}
          restic backup --tag=jellyfin --skip-if-unchanged=true -- data/ config/
        '';
      };
      forget = {
        text = ''
          restic forget --tag=jellyfin --group-by=tag --keep-daily=7 --keep-monthly=12
        '';
      };
    };
  };
}
