{ config, lib, pkgs, machine, data, ... }:

let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
  port = data.ports.forgejo;
in {
  services.forgejo = {
    enable = true;
    database.type = "mysql";

    settings = {
      server = {
        DOMAIN = "git.internal";
        ROOT_URL = "https://${config.l3mon.services.defs.git.network_domain}";
        HTTP_PORT = port;
      };
      service.DISABLE_REGISTRATION = true;
    };
  };
  
  systemd.services.forgejo.preStart = let 
    adminCmd = "${lib.getExe cfg.package} admin user";
  in ''
    ${adminCmd} create --admin --email "simon@l3mon4.de" --username simon --password "temp" --must-change-password=false || true
    ${adminCmd} change-password --username simon --password "$(cat ${config.l3mon.secgen.secrets.forgejo_admin.secret})" --must-change-password=false || true
    ${adminCmd} create --email "katz@cs.uni-bonn.de" --username simon_work --password "temp" --must-change-password=false || true
    ${adminCmd} change-password --username simon_work --password "$(cat ${config.l3mon.secgen.secrets.forgejo_work.secret})" --must-change-password=false || true
  '';

  l3mon.secgen.secrets = {
    forgejo_admin = config.lib.l3mon.secgen.direct_secret { owner = "forgejo"; id = "forgejo_admin"; };
    forgejo_work = config.lib.l3mon.secgen.direct_secret { owner = "forgejo"; id = "forgejo_work"; };
  };

  # override module-level rules for forgejo (specifically for .ssh).
  systemd.tmpfiles.rules = lib.mkAfter [
    "A ${cfg.stateDir} - - - - g:forgejo:rX"
    "z '${cfg.stateDir}/.ssh' 0750 forgejo forgejo"
  ];

  l3mon.services.defs.git = {
    cfg = port;
    networks = with config.lib.l3mon.networks; [ physical.home virtual.home virtual.work ];
  };

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
