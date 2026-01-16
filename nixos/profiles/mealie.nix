{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

{
  services.mealie = {
    enable = true;
    port = data.ports.mealie;
  };

  users.users.mealie = {
    isSystemUser = true;
    uid = data.ids.mealie;
    group = "mealie";
  };
  users.groups.mealie.gid = data.ids.mealie;
  
  systemd.services.mealie.serviceConfig = {
    User = "mealie";
    Group = "mealie";
    DynamicUser = lib.mkForce false;
  };

  l3mon.services.defs.mealie.cfg = data.ports.mealie;

  l3mon.restic.extraGroups = [ "mealie" ];
  l3mon.restic.specs.mealie = {
    backupStopResumeServices = ["mealie.service"];
    backupDaily = {
      text = ''
        cd /var/lib/mealie/
        restic backup --tag=mealie --skip-if-unchanged=true -- ./recipes ./templates ./users
      '';
    };
    forget = {
      text = ''
        restic forget --tag=mealie --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
