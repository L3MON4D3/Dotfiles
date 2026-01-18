{ config, lib, pkgs, machine, data, ... }:

{
  services.silverbullet = {
    enable = true;
    listenPort = data.ports.silverbullet;
  };

  users.users.silverbullet = {
    isSystemUser = true;
    uid = data.ids.silverbullet;
    group = "silverbullet";
  };
  users.groups.silverbullet.gid = data.ids.silverbullet;

  l3mon.services.defs.sb.cfg = data.ports.silverbullet;

  l3mon.restic.extraGroups = [ "silverbullet" ];
  l3mon.restic.specs.silverbullet = {
    backupDaily = {
      text = ''
        cd /var/lib/silverbullet/
        restic backup --tag=silverbullet --skip-if-unchanged=true -- ./*
      '';
    };
    forget = {
      text = ''
        restic forget --tag=silverbullet --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
