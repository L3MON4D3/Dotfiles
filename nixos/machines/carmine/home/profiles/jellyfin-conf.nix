{ config, lib, pkgs, machine, data, ... }:

{
  # maybe have to update this?
  xdg.configFile."jellyfin-mpv-shim/cred.json".text = ''
    [{"address": "http://jellyfin.internal:80", "Name": "indigo", "Id": "19115077000e43dca1172812a4f96c59", "Version": "10.10.3", "DateLastAccessed": "2025-02-14T01:10:13Z", "UserId": "db65cdf9d37b4d7cb0fdfe39058c5657", "AccessToken": "5d257143d72e4e5aa5a77f111075f596", "Users": [{"Id": "db65cdf9d37b4d7cb0fdfe39058c5657", "IsSignedInOffline": true}], "uuid": "684f0a2a-1753-4bc7-aee4-62ca0553a5bd", "username": "simon", "connected": true}]
  '';
}
