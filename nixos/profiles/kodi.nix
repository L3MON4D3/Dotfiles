{ config, lib, pkgs, machine, data, ... }:

with lib;
let

in
{
  services.mysql = {
    ensureUsers = [
      {
        name = "kodi";
        ensurePermissions = {
          # https://kodi.wiki/view/MySQL/Setting_up_MySQL#tab=Restricting_MySQL_access_rights
          "*.*" = "ALL PRIVILEGES";
        };
        remotePassword = "kodi";
      }
      {
        # for backup
        name = "restic";
        ensurePermissions = {
          "*.*" = "SELECT, SHOW VIEW, TRIGGER, LOCK TABLES";
        };
      }
    ];
  };

  l3mon.restic.specs.kodi = {
    backupDaily = {
      runtimeInputs = [ config.services.mysql.package ];
      text = ''
        mysqldump MyVideos131 | restic backup --tag=kodi --stdin --stdin-filename=MyVideos131 --skip-if-unchanged=true
      '';
    };
    backup15min = {
      text = ''
        echo lel
      '';
    };
    forget = {
      text = ''
        restic forget --tag=kodi --group-by=tag --keep-monthly=2
      '';
    };
  };
}
