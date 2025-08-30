{ config, lib, pkgs, machine, data, ... }:

let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
  machine_lan_address = data.network.lan.peers.${machine}.address;
  port = data.ports.forgejo;
in {
  services.forgejo = {
    enable = true;
    database.type = "mysql";

    settings = {
      server = {
        DOMAIN = "git.internal";
        ROOT_URL = "http://${srv.DOMAIN}";
        HTTP_PORT = port;
      };
      service.DISABLE_REGISTRATION = true;
    };
  };

  
  systemd.services.forgejo.preStart = let 
    adminCmd = "${lib.getExe cfg.package} admin user";
    user = "simon"; # Note, Forgejo doesn't allow creation of an account named "admin"
  in ''
    ${adminCmd} create --admin --email "simon@l3mon4.de" --username ${user} --password "bbbbbbbb" || true
  '';

  services.caddy.extraConfig = ''
    http://git, http://git.internal, http://git.${machine} {
      reverse_proxy http://${machine_lan_address}:${toString port}
    }
  '';

  # override module-level rules for forgejo (specifically for .ssh).
  systemd.tmpfiles.rules = lib.mkAfter [
    "A ${cfg.stateDir} - - - - g:forgejo:rX"
    "z '${cfg.stateDir}/.ssh' 0750 forgejo forgejo"
  ];

  l3mon.restic.extraGroups = [ "forgejo" ];
  l3mon.restic.dailyRequiredServices = [ "mysql.service" ];
  l3mon.restic.specs.forgejo = {
    backupStopResumeServices = ["forgejo.service"];
    # create two tags, one for files and one for the database-backup.
    # I don't think both can be put into one snapshot easily if I want to use
    # the `--stdin`-option.
    # This is fine though :)
    backupDaily = {
      text = ''
        cd ${cfg.stateDir}
        restic backup --tag=forgejo-data --skip-if-unchanged=true -- repositories data .ssh
        mysqldump forgejo | restic backup --tag=forgejo-db --skip-if-unchanged=true --stdin --stdin-filename=forgejo.mysql
      '';
      runtimeInputs = [ config.services.mysql.package ];
    };
    forget = {
      text = ''
        restic forget --tag=forgejo-data --group-by=tag --keep-daily=7 --keep-monthly=12
        restic forget --tag=forgejo-db --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
