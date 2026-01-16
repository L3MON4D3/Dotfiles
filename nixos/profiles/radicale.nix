{ config, lib, pkgs, machine, data, ... }:

let
  port = data.ports.radicale;
in {
  services.radicale = {
    enable = true;
    settings = {
      storage.filesystem_folder = "/var/lib/radicale/collections";
      server = {
        hosts = "0.0.0.0:${toString port}";
        max_connections = 20;
        max_content_length = 1000000000;
        timeout = 30;
      };
      auth.type = "none";
    };
  };

  l3mon.services.defs.radiacle.cfg = port;

  l3mon.restic.extraGroups = [ "radicale" ];
  l3mon.restic = {
    specs.radicale = {
      backupStopResumeServices = [ "radicale.service" ]; 
      backupDaily = {
        text = ''
          cd /var/lib/radicale
          restic backup --tag=radicale --skip-if-unchanged=true -- *
        '';
      };
      forget = {
        text = ''
          restic forget --tag=radicale --group-by=tag --keep-last=10
        '';
      };
    };
  };
}
