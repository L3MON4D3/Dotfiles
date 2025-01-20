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
    ];
  };
}
