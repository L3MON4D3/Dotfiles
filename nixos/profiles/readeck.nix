{ config, lib, pkgs, machine, data, l3lib, ... }:

let
  machine_lan_address = data.network.lan.peers.${machine}.address;
in {
  services.readeck = {
    enable = true;
    settings = {
      server = {
        port = data.ports.readeck;
        host = "127.0.0.1";
        trusted_proxies = ["127.0.0.1"];
        allowed_hosts = ["readeck.internal"];
      };
    };
  };

  users.users.readeck = {
    isSystemUser = true;
    uid = data.ids.readeck;
    group = "readeck";
  };
  users.groups.readeck.gid = data.ids.readeck;
  
  systemd.services.readeck.serviceConfig = {
    LoadCredential = "secret_key:${l3lib.secret "readeck_secret_key"}";
    Environment = "READECK_SECRET_KEY=%d/secret_key";
    User = "readeck";
    Group = "readeck";
    DynamicUser = lib.mkForce false;
  };

  services.caddy.extraConfig = ''
    http://readeck, http://readeck.internal, http://readeck.${machine} {
      reverse_proxy http://127.0.0.1:${toString data.ports.readeck}
    }
  '';

  l3mon.restic.extraGroups = [ "readeck" ];
  l3mon.restic.specs.readeck = {
    backupStopResumeServices = ["readeck.service"];
    backupDaily = {
      text = ''
        cd /var/lib/readeck/
        restic backup --tag=readeck --skip-if-unchanged=true -- ./data
      '';
    };
    forget = {
      text = ''
        # For each known file (torrent), keep last snapshot where it existed.
        # This makes sure every torrent-file still exists somewhere in the restic-repository.
        restic forget --tag=readeck --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
