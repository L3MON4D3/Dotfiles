{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  machine_lan_address = data.network.lan.peers.${machine}.address;
in {
  services.jellyfin.enable = true;
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  
  services.caddy.extraConfig = ''
    http://jellyfin, http://jellyfin.internal, http://jellyfin.${machine} {
      reverse_proxy http://${machine_lan_address}:${data.ports.jellyfin_web}
    }
  '';

  users.users.restic.extraGroups = [ "jellyfin" ];
  # allow group read-access so restic can read everything.
  systemd.services.jellyfin.serviceConfig.UMask = mkForce 0027;

  # override rules from jellyfin-module
  systemd.tmpfiles.settings.jellyfinDirs = {
    "${config.services.jellyfin.dataDir}"."d" = mkForce {
      mode = "750";
      inherit (config.services.jellyfin) user group;
    };
    "${config.services.jellyfin.configDir}"."d" = mkForce {
      mode = "750";
      inherit (config.services.jellyfin) user group;
    };
  };

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
