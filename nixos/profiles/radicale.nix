{ config, lib, pkgs, machine, data, ... }:

let
  port = data.ports.radicale;
  machine_lan_address = data.network.lan.peers.${machine}.address;
in {
  services.radicale = {
    enable = true;
    settings = {
      storage.filesystem_folder = "/var/lib/radicale/collections";
      server = {
        hosts = "0.0.0.0:${port}";
        max_connections = 20;
        max_content_length = 1000000000;
        timeout = 30;
      };
      auth.type = "none";
    };
  };

  services.caddy.extraConfig = ''
    http://radicale, http://radicale.internal, http://radicale.${machine} {
      reverse_proxy http://${machine_lan_address}:5232
    }
  '';

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
